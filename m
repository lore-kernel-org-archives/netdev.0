From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Tue, 17 Jan 2006 19:48:34 +0100
Message-ID: <20060117184834.GD19398@stusta.de>
References: <20060105181826.GD12313@stusta.de> <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru> <20060115160340.6f8cc7d6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vitaly Bordug <vbordug@ru.mvista.com>, jgarzik@pobox.com,
	saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932399AbWAQSsh@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060115160340.6f8cc7d6@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2006 at 04:03:40PM -0800, Stephen Hemminger wrote:
> On Sun, 15 Jan 2006 16:19:58 +0300
> Vitaly Bordug <vbordug@ru.mvista.com> wrote:
> 
> > On Thu, 5 Jan 2006 19:18:26 +0100
> > Adrian Bunk <bunk@stusta.de> wrote:
> > 
> > > This patch removes the obsolete drivers/net/eepro100.c driver.
> > > 
> > > Is there any known problem in e100 still preventing us from removing 
> > > this driver (it seems noone was able anymore to verify the ARM problem)?
> > > 
> > I think I am recalling some problems on ppc82xx, when e100 was stuck on startup,
> > and eepro100 worked just fine. 
> > 
> > Even if the patch below will be scheduled for application, we need to set up enough time 
> > for approval that e100 will be fine for all the up-to-date hw; or it should be fixed/updated before eepro100 removal.
> > 
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > > 
> > >
> 
> How about doing what was done with devfs removal, and remove it
> from the config menu system for a couple of releases.

IMHO the devfs case was different since the complete devfs removal patch 
(although being straightforward) touches many files.

In the eepro100 case (assuming there were no more known regressions in 
the e100 driver), reverting the removal patch would be trivial.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
