From: Adrian Bunk <bunk@kernel.org>
Subject: Re: 2.6.23-rc4-mm1 "no CRC" MODPOST warnings
Date: Sun, 2 Sep 2007 00:40:46 +0200
Message-ID: <20070901224046.GP9260@stusta.de>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <alpine.LFD.0.999.0709020327260.20781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56574 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757470AbXIAWkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 18:40:45 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709020327260.20781@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 03:36:08AM +0530, Satyam Sharma wrote:
> 
> 
> On Fri, 31 Aug 2007, Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> 
> Got these on an i386 build with CONFIG_MODVERSIONS=y ...
> 
> WARNING: "div64_64" [net/netfilter/xt_connbytes.ko] has no CRC!
> WARNING: "div64_64" [net/ipv4/tcp_cubic.ko] has no CRC!
>...

That's expected since the fix is in git-kbuild.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

