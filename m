From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix initialization of PHYCR register
Date: Sat, 2 Jul 2016 10:01:34 -0700
Message-ID: <5777F36E.6090105@gmail.com>
References: <1467405303-19212-1-git-send-email-stefan@shauser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stefan Hauser <stefan@shauser.net>, netdev@vger.kernel.org,
	Dan Murphy <dmurphy@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36776 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbcGBRBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 13:01:38 -0400
Received: by mail-oi0-f41.google.com with SMTP id f189so148856742oig.3
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 10:01:37 -0700 (PDT)
In-Reply-To: <1467405303-19212-1-git-send-email-stefan@shauser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/07/2016 13:35, Stefan Hauser a =C3=A9crit :
> When initializing the PHY control register, the FIFO depth bits are
> written without reading the previous register value, i.e. all other
> bits are overwritten with zero. This disables automatic MDI-X
> configuration, which is enabled by default. Fix initialization by doi=
ng
> a read/modify/write operation.
>=20
> Signed-off-by: Stefan Hauser <stefan@shauser.net>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
=46ixes: 2a10154abcb7 ("net: phy: dp83867: Add TI dp83867 phy")
--=20
=46lorian
