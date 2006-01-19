From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels
Date: Thu, 19 Jan 2006 01:57:37 +0100
Message-ID: <200601190157.38277.arnd@arndb.de>
References: <1137122079.5589.34.camel@spereira05.tusc.com.au> <200601170115.07019.arnd@arndb.de> <1137567396.14130.2.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>, acme@ghostprotocols.net, ak@muc.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pereira.shaun@gmail.com, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161126AbWASA6E@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1137567396.14130.2.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Wednesday 18 January 2006 07:56 schrieb Shaun Pereira:
> =C2=A0Assuming you are happy with the state of the patches, is there =
anyway
> for me to know if they will become a part of the next release?

I don't see any more technical problems with your patches. You still ne=
ed
to proper patch description and Signed-off-by: line like it is describe=
d
in Documentation/SubmittingPatches.
You can add an 'Acked-by: Arnd Bergmann <arnd@arndb.de>' line to the fo=
ur
patches you posted last if you like.

> Usually submitted/reviewed patches to netdev does not not always
> guarantee they will be acccepted/signed-off.
> Any advice would be useful

I'm not that familiar with the process for non-driver patches for netde=
v
(nor for device drivers as it seems ;-)), but my understanding is that =
you=20
should address those to Jeff Garzik as well, asking for inclusion in th=
e
netdev-2.6 git tree in your introductory '[PATCH 0/4]' mail.

Since the official merge window for 2.6.16 is now over (2.6.16-rc1 has =
been
released), it may have to wait for 2.6.17 to become part of the mainlin=
e
kernel, that probably depends on Jeffs judgement.

I would think it can still go in since it is a bug fix for the executio=
n of
32 bit programs using x25 ioctls, but it's clearly not my decision ;-).

	Arnd <><
