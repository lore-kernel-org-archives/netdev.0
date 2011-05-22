From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: PA-RISC: compile error in include/net/dst.h
Date: Sun, 22 May 2011 14:13:58 +0000 (UTC)
Message-ID: <irb5n6$vn3$1@dough.gmane.org>
References: <2612811.b2htuyZy9x@donald.sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-parisc@vger.kernel.org, stable@linux.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc netdev as well)

On Sun, 22 May 2011 10:15:19 +0200, Rolf Eike Beer wrote:

> from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:25,
>                  from include/linux/nfs_fs.h:50,
>                  from init/do_mounts.c:20:
> include/net/dst.h: In function 'dst_hold': include/net/dst.h:238:2:
> error: size of unnamed array is negative In file included from
> include/linux/nfs_fs.h:59:0,
>                  from init/do_mounts.c:20:


Seems someone touched struct dst_entry...

> include/linux/mempool.h: In function 'mempool_create_kmalloc_pool':
> include/linux/mempool.h:58:10: warning: cast to pointer from integer of
> different size
> 
> This is both in 2.6.38.6 and 2.6.39, but is not in 2.6.38.4 when
> compiling for my C8000.
> 
> pioneer src #  hppa64-unknown-linux-gnu-gcc --version
> hppa64-unknown-linux-gnu-gcc (Gentoo 4.5.2 p1.1) 4.5.2
> 
> Greetings,
> 
> Eike
