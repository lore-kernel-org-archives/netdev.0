From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: [Bugme-new] [Bug 7724] New: asm/types.h should define __u64 if isoc99
Date: Thu, 21 Dec 2006 23:03:15 +0200
Message-ID: <200612212303.16136.ismail@pardus.org.tr>
References: <200612211617.kBLGHAAg028181@fire-2.osdl.org> <20061221124954.6bb415e9.akpm@osdl.org> <20061221.125850.125884789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, uberlord@gentoo.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:56994 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423033AbWLUV1v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 16:27:51 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061221.125850.125884789.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

21 Ara 2006 Per 22:58 tarihinde, David Miller =C5=9Funlar=C4=B1 yazm=C4=
=B1=C5=9Ft=C4=B1:=20
> From: Andrew Morton <akpm@osdl.org>
> Date: Thu, 21 Dec 2006 12:49:54 -0800
>
> > >            Summary: asm/types.h should define __u64 if isoc99
>
> Platform specific bug, and has nothing to do with networking.
>
> This problem will occur with any user visible interface definition
> that uses __u64, and there are several both in and outside the
> networking.

This bug hit KDE modules (kdebase/kdemultimedia/kdetv/...) many times, =
I=20
workarounded with #undef ing __STRICT_ANSI__ before including kernel he=
aders=20
which is well ugly but works.

> x86 and perhaps others protect the __u64 definition with:
>
> 	defined(__GNUC__) && !defined(__STRICT_ANSI__)
>
> for whatever reason, probably to avoid "long long" or something like
> that.  But even that theory makes no sense.

Indeed this restriction just breaks userspace apps.

Regards,
ismail

--=20
Bir g=C3=BCn yolda y=C3=BCr=C3=BCyordum... Bir =C5=9Fark=C4=B1 duydum..=
=2E Kalbim ac=C4=B1d=C4=B1... Bu kadar...
