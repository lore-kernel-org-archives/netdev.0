From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Mon, 16 Jan 2006 01:08:22 +0100
Message-ID: <20060116000822.GD29663@stusta.de>
References: <20060105181826.GD12313@stusta.de> <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932092AbWAPAIX@vger.kernel.org>
To: Vitaly Bordug <vbordug@ru.mvista.com>
Content-Disposition: inline
In-Reply-To: <20060115161958.07e3c7f1@vitb.dev.rtsoft.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2006 at 04:19:58PM +0300, Vitaly Bordug wrote:
> On Thu, 5 Jan 2006 19:18:26 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > This patch removes the obsolete drivers/net/eepro100.c driver.
> > 
> > Is there any known problem in e100 still preventing us from removing 
> > this driver (it seems noone was able anymore to verify the ARM problem)?
> > 
> I think I am recalling some problems on ppc82xx, when e100 was stuck on startup,
> and eepro100 worked just fine. 
> 
> Even if the patch below will be scheduled for application, we need to set up enough time 
> for approval that e100 will be fine for all the up-to-date hw; or it should be fixed/updated before eepro100 removal.

How/When can you/someone else test this?

Do the e100 maintainers (Cc'ed) know about such problems and their 
status?

> Sincerely, 
> Vitaly

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
