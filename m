From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Sun, 30 Sep 2007 11:16:41 -0700
Message-ID: <46FFE809.8020504@intel.com>
References: <1191174077.6165.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:65353 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbXI3SRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 14:17:08 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JP7006WO1FVCY89@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 30 Sep 2007 13:16:44 -0500 (CDT)
In-reply-to: <1191174077.6165.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Auke,
> 
> heres part of something i promised. 
> I couldnt do any packet testing on because 82571EB is disabled in the
> driver. I uncommented the code out in the table, but the best i could
> get was the module loading, some probing and some sysfs renaming
> failures (probably a debianism); the machine access is intermittent, so
> thats as far as i could go. In any case, you probably have a good reason
> for disabling that chip. So, heres the patch, the burden of testing now
> falls on you ;->

no, all the hardware that is commented should work just fine. I tested this driver
on 82571, 82573 and ich8/ich9 - extensively.

the reason that we disable them is that we're going to migrate devices over in
batches. At introduction we'll support ich9, afterwards we'll drop in the IDs of
the other groups of silicon.

> Once you have 82571EB on and kicking, my next steps are to kill LLTX
> then add batching on top.
> BTW, since this driver is just for PCIE, would you take a similar patch
> for non-PCIE e1000?

if it's a fix, yes.

> comment:
> There used to be an "mmiowb()" call right after the dma wake which is
> gone now; is this unneeded with pcie? I have restored it, look for the
> "XXX".


thanks, I'll go and look at this in depth in the coming weeks.

Auke
