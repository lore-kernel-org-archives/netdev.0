From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined
	reference to `ei_close'
Date: Thu, 24 Jul 2008 07:26:03 +0200
Message-ID: <20080724052603.GA8744@elte.hu>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp> <20080721191519.GA15843@elte.hu> <20080721214258.787a67ca@lxorguk.ukuu.org.uk> <20080722072334.GA25241@elte.hu> <48865899.3030209@garzik.org> <20080723104520.GA20672@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753052AbYGXF06@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080723104520.GA20672@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


not sure it's known but despite all the fixes i still get:

 drivers/built-in.o: In function `ne_drv_resume':
 ne.c:(.text+0x146ba4): undefined reference to `NS8390_init'
 drivers/built-in.o: In function `ne_block_output':
 ne.c:(.text+0x146e00): undefined reference to `NS8390_init'
 drivers/built-in.o: In function `hpp_close':
 hp-plus.c:(.text+0x148c3b): undefined reference to `ei_close'
 drivers/built-in.o: In function `hpp_open':
 hp-plus.c:(.text+0x148c77): undefined reference to `ei_interrupt'
 hp-plus.c:(.text+0x148ce7): undefined reference to `ei_open'
 drivers/built-in.o: In function `ne_probe1':
 ne.c:(.init.text+0xb532): undefined reference to `NS8390_init'
 drivers/built-in.o: In function `hpp_probe1':
 hp-plus.c:(.init.text+0xc033): undefined reference to `ei_poll'
 drivers/built-in.o: In function `hp_plus_probe':
 (.init.text+0xc134): undefined reference to `__alloc_ei_netdev'
 make: *** [.tmp_vmlinux1] Error 1

with this config and latest -git (v2.6.26-6371-g338b9bb):

 http://redhat.com/~mingo/misc/config-Thu_Jul_24_07_13_29_CEST_2008.bad

	Ingo
