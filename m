From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 16:39:58 +0100 (BST)
Message-ID: <902045.66378.qm@web29504.mail.ird.yahoo.com>
References: <20101025142232.GC2414@tuxdriver.com>
Reply-To: htl10@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Serafeim Zanikolas <sez@debian.org>, herton@mandriva.com.br,
	joe@perches.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web29504.mail.ird.yahoo.com ([77.238.189.131]:27801 "HELO
	web29504.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756508Ab0JYPql convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 11:46:41 -0400
In-Reply-To: <20101025142232.GC2414@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- On Mon, 25/10/10, John W. Linville <linville@tuxdriver.com> wrote:

> > I had a quick look for similiar constructs and AFAIK
> only the
> > b43/b43legacy drivers uses DMA buffers. Seems to be a
> rare practice.
> > Is that something we should or should not do?
>=20
> It doesn't mean what you think it means.=A0 It is a
> relic of the past,
> used to indicate memory below 16MB so that ISA devices
> could do DMA.

okay - sorry about the confusion - I was grep'ing for GFP_DMA and only =
b43/b43lagacy have it and it is relatively rare. AFAIK none of the rtl8=
187 devices are non-USB... probably a NACK then, but I should ask Seraf=
eim if there is a reason for him to submit this patch? (other than "it =
says dma"...)=20

Hin-tak


     =20
