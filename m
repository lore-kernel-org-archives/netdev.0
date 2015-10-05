From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [net-next:master 647/682] fib_semantics.c:undefined reference
 to `__divdi3'
Date: Mon, 5 Oct 2015 23:31:58 +0200
Message-ID: <20151005233158.2c09adce@tyr>
References: <201510051816.pL2fiACx%fengguang.wu@intel.com>
	<20151005.042638.1280563834697071426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:42477 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbbJEVcC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 17:32:02 -0400
In-Reply-To: <20151005.042638.1280563834697071426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 Oct 2015 04:26:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Mon, 5 Oct 2015 18:54:18 +0800
>=20
> > tree:
> > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> > master head:   937317c7c1097aa878a5000e3aab616eb5c590c0 commit:
> > 0e884c78ee19e902f300ed147083c28a0c6302f0 [647/682] ipv4: L3
> > hash-based multipath config: i386-defconfig (attached as .config)
> > reproduce: git checkout 0e884c78ee19e902f300ed147083c28a0c6302f0
> >         # save the attached .config to linux build tree
> >         make ARCH=3Di386=20
> >=20
> > All errors (new ones prefixed by >>):
> >=20
> >    net/built-in.o: In function `fib_rebalance':
> >>> fib_semantics.c:(.text+0x9df14): undefined reference to `__divdi3=
'
>=20
> Peter please fix this.

Darn! Didn't consider that 32-bit architectures would behave
differently. I'll remember to at also test on i386 and ARM in the
future.

What is the proper way to supply fixes for this kind of errors? Should
I submit the original patches again with the bug fixed, or should I
submit a patch fixing this particular problem? I imagine bisecting
becomes annoying when a particular commit doesn't compile.

The ARM compilation errors is apparently solved by the same fix.

Best Regards
 Peter N=C3=B8rlund
