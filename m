From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 7 Jun 2005 18:34:21 +0200
Message-ID: <17061.52365.336303.369135@robur.slu.se>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>
	<Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
	<42A5284C.3060808@osdl.org>
	<1118147904.6320.108.camel@localhost.localdomain>
	<Pine.LNX.4.58.0506071351080.16594@tux.rsn.bth.se>
	<1118150948.6320.152.camel@localhost.localdomain>
	<Pine.LNX.4.58.0506071432570.16594@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@osdl.org>,
        Mitch Williams <mitch.a.williams@intel.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <Pine.LNX.4.58.0506071432570.16594@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Martin Josefsson writes:

 > > So it is possible that the e1000 is doing more than necessary share of
 > > IO on the receive side as well.
 > 
 > Yes, that's what I mean. Same thing but for RX but the question is how
 > much we would gain from it, we still need to touch the rx-descriptor
 > sooner or later. Would be worth a test.
 > My testsetup isn't in a working condition right now, Robert?

 Next week possibly... but really now idea what's to test or whats going on.

 We have dual TCP server with one NIC. How is setup now? I don't know even
 how it should be setup for maximum TCP performance? 

 How is irq affinity setup?  Is irq's jumping between the CPU:s etc?
 Does ksoftirq(s) use CPU?   If so it can be adjusted tuned too.
 How is packets processes by CPU's. /proc/net/softnet_stat. Do we see 
 drops w. one CPU too etc
 It might be intricate question of balance between softirq and userland.

 Cheers.
						--ro

 BTW, Can netperf be used for tests like this? (Rick?)
 
 
