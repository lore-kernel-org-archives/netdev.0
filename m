From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [RFC: -mm patch] improve the SSB dependencies
Date: Mon, 13 Aug 2007 00:44:02 +0200
Message-ID: <20070812224401.GA18945@stusta.de>
References: <200708110208.21624.mb@bu3sch.de> <200708111642.39348.mb@bu3sch.de> <20070811230855.GA8907@stusta.de> <200708121400.28297.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:49461 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932211AbXHLWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 18:44:13 -0400
Content-Disposition: inline
In-Reply-To: <200708121400.28297.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 02:00:26PM +0200, Michael Buesch wrote:
> Ok, I'll give it a try, with small modifications.

Thanks.

> On Sunday 12 August 2007, Adrian Bunk wrote:
> > Additional changes in this patch:
> > - small help text changes
> > - B44_PCI is no longer usr visible (automatically enabled when possible)
> 
> I think we want that to be selectable, as it's not needed
> on some embedded devices. And we need to save memory there.
>...

Makes sense, but then:

config B44_PCI
	bool "Broadcom 440x PCI device support" if EMBEDDED
	...
	default y
	...

I don't care about how many options we present if CONFIG_EMBEDDED=y, but 
for the normal CONFIG_EMBEDDED=n case we should not bother the user with 
this option.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

