From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.13-rc6-mm1: too many 'ipv4_table' variables
Date: Fri, 19 Aug 2005 19:28:42 +0200
Message-ID: <20050819172842.GG3682@stusta.de>
References: <20050819043331.7bc1f9a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932567AbVHSR2q@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050819043331.7bc1f9a9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2005 at 04:33:31AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.13-rc5-mm1:
>...
>  git-net.patch
>...
>  Subsystem trees
>...

It seems there are too many different 'ipv4_table' variables:

<--  snip  -->

...
  CC      net/ipv4/ipvs/ip_vs_ctl.o
net/ipv4/ipvs/ip_vs_ctl.c:1601: error: static declaration of 'ipv4_table' follows non-static declaration
include/net/ip.h:376: error: previous declaration of 'ipv4_table' was here
make[3]: *** [net/ipv4/ipvs/ip_vs_ctl.o] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
