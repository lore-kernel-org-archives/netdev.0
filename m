From: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
Subject: Re: [PATCH] tcp: efficient port randomisation (revised)
Date: Mon, 6 Dec 2004 09:18:04 +0100
Message-ID: <200412060918.04441.michael.vittrup.larsen@ericsson.com>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net> <20041202135252.04e64f51.davem@davemloft.net> <41B14E57.5080803@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <41B14E57.5080803@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Measuring non-blocking connect using the loopback address I agree with 
Stephen' conclusion, that the cost of the MD4 gets lost in the noise.

I did not measure the variance, since this probably describe scheduling and 
not the actual ephemeral bind.  However, I did measure the minimum value, and 
the assumption is that this is close to a measurement of an uninterrupted 
connect.  Median filtering probably would be more correct...

Below are the results from 10 successive tests.

Unmodified (average and minimum values):

connect 24433 (min 21820) [ticks/op]
connect 24504 (min 21927) [ticks/op]
connect 24530 (min 21952) [ticks/op]
connect 24244 (min 21607) [ticks/op]
connect 24220 (min 21613) [ticks/op]
connect 24117 (min 21665) [ticks/op]
connect 24148 (min 21663) [ticks/op]
connect 24079 (min 21648) [ticks/op]
connect 23998 (min 21700) [ticks/op]
connect 23906 (min 21682) [ticks/op]

Modified (average and minimum values):

connect 23961 (min 21774) [ticks/op]
connect 23894 (min 21750) [ticks/op]
connect 23927 (min 21776) [ticks/op]
connect 23881 (min 21757) [ticks/op]
connect 23956 (min 21749) [ticks/op]
connect 23872 (min 21710) [ticks/op]
connect 23848 (min 21694) [ticks/op]
connect 23729 (min 21769) [ticks/op]
connect 23656 (min 21618) [ticks/op]
connect 23723 (min 21699) [ticks/op]
