From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] ARM: at91/dt: sama5d3 xplained: add phy address for macb1
Date: Fri, 3 Apr 2015 13:55:07 -0700
Message-ID: <20150403205507.GH23023@localhost>
References: <1427792170-13162-1-git-send-email-nicolas.ferre@atmel.com>
 <551E52BC.3040702@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Kevin Hilman <khilman@kernel.org>,
	ARM Maintainers <arm@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Johan Hovold <johan@kernel.org>, stable@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33510 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbbDCUzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:55:09 -0400
Received: by pdbnk13 with SMTP id nk13so52105618pdb.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:55:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <551E52BC.3040702@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2015 at 10:43:40AM +0200, Nicolas Ferre wrote:
> Le 31/03/2015 10:56, Nicolas Ferre a =E9crit :
> > After 57a38effa598 (net: phy: micrel: disable broadcast for KSZ8081=
/KSZ8091)
> > the macb1 interface refuses to work properly because it tries
> > to cling to address 0 which isn't able to communicate in broadcast =
with
> > the mac anymore. The micrel phy on the board is actually configured
> > to show up at address 1.
> > Adding the phy node and its real address fixes the issue.
> >=20
> > Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> > Cc: Johan Hovold <johan@kernel.org>
> > Cc: <stable@vger.kernel.org> #3.19
> > ---
>=20
> Arnd, Olof, Kevin,
>=20
> It seems late but, is it possible to queue this patch as a 4.0 fixes?
>=20
> Without it, the 10/100 Ethernet on sama5d3 doesn't work if it's not u=
sed
> by u-boot previously.

Sure, resend it to arm@kernel.org.


-Olof
