From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [E1000-devel] WoL stopped working after power off with 2.6.38
	(e1000e specific?)
Date: Mon, 2 May 2011 15:02:05 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001B54CE017@orsmsx509.amr.corp.intel.com>
References: <20110430054519.GA9826@scooby.iskra.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>
To: Kamil Iskra <kamil@iskra.name>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12746 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763Ab1EBWCI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:02:08 -0400
In-Reply-To: <20110430054519.GA9826@scooby.iskra.name>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Kamil Iskra [mailto:kamil@iskra.name]
>Sent: Friday, April 29, 2011 10:45 PM
>To: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
>Subject: [E1000-devel] WoL stopped working after power off with 2.6.38 (e1000e
>specific?)
>
>[ Note: I'm not on these mailing lists, so be sure to Cc: me if you want
>more info from me ]
>
>After upgrading from kernel 2.6.37 to 2.6.38, Wake on LAN after shutdown
>stopped working for me on both of my Thinkpad laptops.  Both systems use
>the e1000e driver.  One (a T61) has an 82566MM NIC, the other (an X201) an
>82577LM.  I'm running 64-bit Gentoo Linux with a custom compiled kernel.
>The network driver is built into the kernel.
>
>Wake on LAN still works after suspend (S3), but not after a complete
>shutdown (with power supply connected).
>
>I figured the updated e1000e driver in 2.6.38 was probably to blame,
>however, after I copied the whole drivers/net/e1000e directory from the
>2.6.37 over to the 2.6.38 tree and recompiled, the problem persisted, so I
>don't know anymore.
>
>I modified the system shutdown sequence to invoke ifconfig and ethtool
>right before the final halt.  According to ifconfig, eth0 is down at that
>point.  According to ethtool, WoL is configured correctly ("Wake-on: g").
>There is, however, a difference in the output of ethtool between the two
>kernel versions.  "Link detected:" shows "yes" with 2.6.37, but "no" with
>2.6.38.
>
>A workaround that I found to work was to invoke "ifconfig eth0 up" right
>before the halt.
>
>Any suggestions?  Is this new behavior expected or is it a bug?

WoL from S5 "works for me"(TM) using the e1000e driver on RHEL6 and 2.6.38.
Could you provide your customer kernel configuration?

Cc: linux-pm@lists.linux-foundation.org

Thanks,
Bruce.
