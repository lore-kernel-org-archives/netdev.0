From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH net-2.6] starfire: Replace broken preprocessor test for
 dma_addr_t size
Date: Tue, 28 Dec 2010 14:39:36 +0900
Message-ID: <20101228143936X.fujita.tomonori@lab.ntt.co.jp>
References: <1293509989.2928.99.camel@localhost>
	<AANLkTinx-n045io5bPT-u_7T5cEiu6+74p30=94vkhPU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, davem@davemloft.net, ionut@badula.org,
	netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp,
	akpm@linux-foundation.org, ralf@linux-mips.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:33925 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab0L1GLH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 01:11:07 -0500
In-Reply-To: <AANLkTinx-n045io5bPT-u_7T5cEiu6+74p30=94vkhPU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Dec 2010 14:27:44 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> 2010/12/28 Ben Hutchings <ben@decadent.org.uk>:
> > Commit 56543af "starfire: use BUILD_BUG_ON for netdrv_addr_t" revea=
led
> > that the preprocessor condition used to find the size of dma_addr_t
> > yielded the wrong result for some architectures and configurations.
> > This was kluged for 64-bit PowerPC in commit 3e502e6 by adding yet
> > another case to the condition. =A0However, some MIPS configurations=
 are
> > still handled incorrectly.
> >
> > Replace the preprocessor test with expressions using ?: or
> > __builtin_choose_expr() as necessary.
>=20
> I remember ARCH_DMA_ADDR_T_64BIT was introduced to handle this kind o=
f
> test easily.
>=20
> So please use CONFIG_ARCH_DMA_ADDR_T_64BIT for this test.
> You may also need to set ARCH_DMA_ADDR_T_64BIT for the MIPS
> architecture correctly.

I already sent CONFIG_ARCH_DMA_ADDR_T_64BIT patch for MIPS. It has
been in -mm:

http://userweb.kernel.org/~akpm/mmotm/broken-out/mips-enable-arch_dma_a=
ddr_t_64bit-with-highmem-64bit_phys_addr-64bit.patch
