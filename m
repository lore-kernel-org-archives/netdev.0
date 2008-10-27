From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for October 27 (netdev/hp-plus)
Date: Mon, 27 Oct 2008 12:33:14 -0700 (PDT)
Message-ID: <20081027.123314.13620544.davem@davemloft.net>
References: <20081027181725.8eb49b5e.sfr@canb.auug.org.au>
	<20081027121956.c21d06be.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: rdunlap@xenotime.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081027121956.c21d06be.rdunlap@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 27 Oct 2008 12:19:56 -0700

> Are there any outstanding patches in this area?
> 
> build-r5284.out:hp-plus.c:(.text+0x2b99a): undefined reference to `eip_interrupt'
> build-r5284.out:hp-plus.c:(.text+0x2ba0d): undefined reference to `eip_open'
> build-r5284.out:hp-plus.c:(.text+0x2baef): undefined reference to `eip_close'
> build-r5284.out:hp-plus.c:(.init.text+0x38ee): undefined reference to `NS8390p_init'
> build-r5284.out:(.init.text+0x3948): undefined reference to `__alloc_eip_netdev'
> build-r5284.out:make[1]: *** [.tmp_vmlinux1] Error 1

Grrr...  hp-plus.c uses the interfaces provided with 8390p.c but the Makefile
links it together with plain 8390.c

This is the most spectacular and longest standing build failure I've ever
seen to be honest :-)
