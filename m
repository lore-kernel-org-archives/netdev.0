From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.19-rc6-mm2: Network device naming starts at 1 instead of 0
Date: Tue, 5 Dec 2006 23:08:50 +0100
Message-ID: <200612052308.51265.rjw@sisk.pl>
References: <4575EDAB.6060305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:42936 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760218AbWLEWOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 17:14:12 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4575EDAB.6060305@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 5 December 2006 23:07, Auke Kok wrote:
> [resend]
> 
> Quick note: I loaded up 2.6.19-rc6-mm2 on a platform here and noticed that the onboard
> e1000 NIC was enumerated to eth1 instead of eth0. on 2.6.18.5 and any other kernel I
> used before, it was properly named eth0 after startup. eth0 itself is completely missing
> (-ENODEV).
> 
> I'll try to see if I can point out the culprit, but perhaps this rings a bell to anyone.

Please try to revert

gregkh-driver-driver-core-fixes-sysfs_create_link-retval-checks-in-core.c.patch

I had some similar problems that went away after I had reverted it.

Greetings,
Rafael


-- 
If you don't have the time to read,
you don't have the time or the tools to write.
		- Stephen King
