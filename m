From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 08:59:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.085921.28790392.davem@redhat.com>
References: <20030616.160856.35828947.davem@redhat.com>
	<20030616232750.GD18484@netnation.com>
	<20030616234937.GE18484@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030616234937.GE18484@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 16 Jun 2003 16:49:37 -0700

   60.0073 seconds passed, avg forwarding rate: 157557.710 pps
   
   ...Looks like a tad worse than with your patch, but not by much. 
   Forwarding rate is still pretty crappy for an Opteron.  Will fiddle
   a bit more tonight to see what I can do.

To be honest, this isn't half-bad for pure DoS load.

This reminds me, maybe a good test would be PPS for "well behaved
flows" in the presence of DoS load.  You'd probably need 4 systems
to carry out such a test accurately.

Because, really, who cares how fast we can forward the DoS traffic
as long as legitimate users still see good metrics.
