From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6.21-rc2-mm2: drivers/net/wireless/libertas/debugfs.c addr bogosity
Date: Thu, 8 Mar 2007 09:02:28 +0100
Message-ID: <20070308080228.GK3441@stusta.de>
References: <20070306004408.d3f6434d.akpm@linux-foundation.org> <20070307224116.GE3441@stusta.de> <20070307150057.4e6342dc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:52862 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751450AbXCHICa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 03:02:30 -0500
Content-Disposition: inline
In-Reply-To: <20070307150057.4e6342dc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 03:00:57PM -0800, Andrew Morton wrote:
> On Wed, 7 Mar 2007 23:41:16 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > On Tue, Mar 06, 2007 at 12:44:08AM -0800, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.20-rc2-mm1:
> > >...
> > >  git-netdev-all.patch
> > >...
> > >  git trees
> > >...
> > 
> > drivers/net/wireless/libertas/debugfs.c contains:
> >   #define item_addr(n) ((u32) &((wlan_adapter *)0)->n)
> > 
> > This is wrong on 64bit architectures.
> 
> Is OK - it is simply yet another reimplementation of offsetof().  Hint.

Thanks for the correction - it seems C pointers and me will never become 
close friends...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

