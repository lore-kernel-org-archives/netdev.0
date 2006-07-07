From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 07 Jul 2006 16:57:44 -0700 (PDT)
Message-ID: <20060707.165744.107703682.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC093F9B2@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:918
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751281AbWGGX5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 19:57:12 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093F9B2@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 7 Jul 2006 14:22:11 -0700

> John W. Linville wrote:
> 
> > Obviously it is between you and Dave to decide what is best.  We are
> > carrying this patch in RHEL4 at the moment, so I didn't want to hold
> > it back from upstream.  If you think you have a better solution then
> > "it's on you"... :-)
> 
> Since 2.6.18 already has the recovery logic in place, we can probably
> holdoff merging this patch upstream.

I think that since we do have a proof positive report, and well
documented success of the fix, we should add the fix even though
we have the fallback thing to take care of it.

This is how we were going to use the fall-back code, to make the the
chipset blacklist more robust yet still allow the user's machine to
work meanwhile.  Here, we have enough information to add the blacklist
entry safely.

What do you think?
