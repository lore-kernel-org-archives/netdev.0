From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] drivers/net/hamradio/: cleanups
Date: Sat, 23 Jul 2005 19:08:04 +0200
Message-ID: <20050723170804.GG3160@stusta.de>
References: <20050502014637.GQ3592@stusta.de> <42BF2BA9.8060502@pobox.com> <20050626155318.7f065d5b.rdunlap@xenotime.net> <42BF337D.1050904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: randy_dunlap <rdunlap@xenotime.net>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262360AbVGWRIM@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42BF337D.1050904@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 26, 2005 at 07:00:13PM -0400, Jeff Garzik wrote:
> randy_dunlap wrote:
> >On Sun, 26 Jun 2005 18:26:49 -0400 Jeff Garzik wrote:
> >
> >| Adrian Bunk wrote:
> >| > This patch contains the following cleanups:
> >| > - dmascc.c: remove the unused global function dmascc_setup
> >| 
> >| Better to use it, then remove it.
> >
> >                    than ??
> 
> Yes.  Use it via __setup() or similar.

Hi Jeff,

I still haven't gotten any answer from you regarding the following 
question:

Can you give me a hint how it should be used?

Why doesn't dmascc_init together with the MODULE_PARM(io,...) work in
the non-modular case?

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
