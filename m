From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 3/6] powerpc: add memory map support to Freescale RapidIO
	block
Date: Thu, 21 May 2009 18:43:23 +0800
Message-ID: <2a27d3730905210343k1e44225eh5555de768abdbb03@mail.gmail.com>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	 <1242117363-14949-2-git-send-email-leoli@freescale.com>
	 <1242117363-14949-3-git-send-email-leoli@freescale.com>
	 <20090512150552.a98dca64.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: galak@kernel.crashing.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, zw@zh-kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:26221 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbZEUKnX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 06:43:23 -0400
In-Reply-To: <20090512150552.a98dca64.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2009 at 6:05 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 12 May 2009 16:36:00 +0800
> Li Yang <leoli@freescale.com> wrote:
>
>> + =C2=A0 =C2=A0 align =3D (size < 0x1000) ? 0x1000 : 1 << (__ilog2(s=
ize - 1) + 1);
>> +
>> + =C2=A0 =C2=A0 /* Align the size */
>> + =C2=A0 =C2=A0 if ((lstart + size) > (_ALIGN_DOWN(lstart, align) + =
align)) {
>
> __ilog2() and _ALIGN_DOWN() are powerpc-specific functions. =C2=A0It =
would
> be preferable to use more general helpers if possible. =C2=A0ALIGN() =
and ilog2()
> might suit here.

Will change to use ilog2().

_ALIGN_DOWN() gets a lower aligned address while ALIGN() gets a higher
address.  It seems that we don't have a general helper to do the same.

- Leo
