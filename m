From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 6 Jan 2005 23:11:05 +0100
Message-ID: <16861.46969.536236.11355@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<200501061520.02362.jeremy.guthrie@berbee.com>
	<16861.44870.968343.578778@robur.slu.se>
	<200501061546.32116.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501061546.32116.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:

 > >  I don't follow...
 > Technically by turning off NAPI, I have 'solved' my short term packet loss 
 > problem.

 You need NAPI of course just wait until your packet load increases just
 a little bit... I saw drops in your 2.4 /proc/net/softnet_stat which 
 indicates you are close to your system performance. With NAPI you keep
 up your system system performance regardless of incoming load. 

 The e1000 driver has some bugs in "your setup" as it enables irq's when
 there is only RX and no TX and should have irq's disabled. I sent patch 
 to intel.

					      --ro
