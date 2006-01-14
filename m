From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Sat, 14 Jan 2006 03:29:49 +0100
Message-ID: <20060114022949.GI29663@stusta.de>
References: <20060112221322.GA25470@havoc.gtf.org> <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org> <20060112143938.5cf7d6a5.akpm@osdl.org> <20060113192316.GX3945@suse.de> <20060113192813.GA10560@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Zippel <zippel@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945982AbWANC3u@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Content-Disposition: inline
In-Reply-To: <20060113192813.GA10560@mars.ravnborg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2006 at 08:28:13PM +0100, Sam Ravnborg wrote:
> On Fri, Jan 13, 2006 at 08:23:16PM +0100, Jens Axboe wrote:
> > 
> > 'select' is really cool as a concept, but when you can't figure out why
> > you cannot disable CONFIG_FOO because CONFIG_BAR selects it it's really
> > annoying. Would be nice to actually be able to see if another option has
> > selected this option.
> 
> In menuconfig:
> 
> Typing '?' on CONFIG_HOTPLUG revealed:
>  Selected by: PCCARD || HOTPLUG_PCI && PCI && EXPERIMENTAL || FW_LOADER
>...

Is there any trick to see them all when they are longer than the line in 
the terminal (e.g. what selects FW_LOADER?)?

> 	Sam

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
