From: Alistair John Strachan <alistair@devzero.co.uk>
Subject: Re: troubles with r8169
Date: Sun, 12 Aug 2007 21:38:58 +0100
Message-ID: <200708122138.58405.alistair@devzero.co.uk>
References: <fa.BZqd/vLw75Xm+ORj+HLjUzU1hSw@ifi.uio.no> <46BF61AB.5060400@shaw.ca> <46BF6853.4020800@lns.pnpi.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Hancock <hancockr@shaw.ca>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vadim Dyadkin <dyadkin@lns.pnpi.spb.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933519AbXHLUjX@vger.kernel.org>
In-Reply-To: <46BF6853.4020800@lns.pnpi.spb.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 12 August 2007 21:06:43 Vadim Dyadkin wrote:
> Robert Hancock =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > This could well be a problem with the nvidia driver as it shares th=
e
> > same IRQ. The first step would be to see if the problem still shows=
 up
> > without the nvidia binary module loaded.
>
> Thank for your answer. This problem never shows up if I use only nvid=
ia
> driver (the work without network), or if I use only r8169 (without
> x.org). If I use both of them I have the hang. Usually the hang appea=
rs
> if OpenGL is used or network rate is maximal. I tested this regimes m=
any
> times before.

If you haven't already, I'd drop linux-bugs@nvidia.com an email to see =
if they=20
have any insight. Not that this can't be a kernel bug, just that it's a=
 bit=20
difficult for kernel developers to debug when you're using a driver for=
 which=20
we don't have the sources.

As for changing the IRQ assignments, I don't have any immediate suggest=
ions. I=20
notice that this laptop has a dual core processor, so I'm guessing disa=
bling=20
APIC isn't an option. Have you tried that anyway, just to see if the IR=
Q=20
assignment differs?

--=20
Cheers,
Alistair.

137/1 Warrender Park Road, Edinburgh, UK.
