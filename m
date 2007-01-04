From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 0/5] qla3xxx:resubmit support for Qlogic 4032 and fixes.
Date: Wed, 3 Jan 2007 16:25:03 -0800
Message-ID: <20070104002503.GB22318@linux-7mw0.qlogic.org>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org> <45919563.9030304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:45355 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189AbXADAZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:25:06 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45919563.9030304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-organized previous 5 patches into 3 patches.

1. Bug fix - remove NETIF_F_LLTX flag from features.
2. Bug fix - Add delay to NVRAM access.  See patch for detailed answer to your questions.
3. Combined patches 1 and 5 that add new chip support (and fixed bug in first 1/5 patch).
(removed patch 2/5 as unecessary)

Ron

> Ron Mercer wrote:
> >These 5 patches were submitted on Dec 5th (1&2) and Dec 11th (3-5).  They 
> >add/fix the following
> >
> >1. Add support for Qlogic 4032 chip.
> >2. Change minor version for 4032 support.
> >3. Add delay when accessing NVRAM.
> >4. Remove NETIF_F_LLTX flag from features.  It was left over from the 
> >early driver and shouldn't be there.
> >5. Fix rx checksum warning.
> >
> >We didn't get any feedback on any of these previously posted patches and 
> >couldn't find a tree where they were added.  We've build and tested them 
> >on 2.6.20-rc1.
> >
> >These patches must be applied in order.
> 
> Please:
> 
> 1) Fix your Mail-Followup-To header, so that it doesn't cause CC's to be 
> trimmed.
> 
> 2) Re-order the patches so that bug fixes come first.  Otherwise this 
> entire patchset must go into netdev-2.6.git#upstream, because patch #1 
> is not a bug fix and we are in a bug-fixes-only cycle.
> 
> 3) Regarding patch #3:  have you verified that a missing PCI flush was 
> not the cause of your problems?  It seems like udelay(1) could be removed?
> 
> ACK the other stuff
> 
> 	Jeff
> 
> 
