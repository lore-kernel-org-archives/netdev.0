From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] caif: Bugfix for socket priority, bindtodev and
 dbg channel.
Date: Wed, 03 Nov 2010 18:56:48 -0700 (PDT)
Message-ID: <20101103.185648.260104666.davem@davemloft.net>
References: <1288648368-9062-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andre.carvalho.matos@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37005
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754769Ab0KDB4Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 21:56:24 -0400
In-Reply-To: <1288648368-9062-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>
Date: Mon,  1 Nov 2010 22:52:47 +0100

> From: Andr=E9 Carvalho de Matos <andre.carvalho.matos@stericsson.com>
>=20
> Changes:
> o Bugfix: SO_PRIORITY for SOL_SOCKET could not be handled
>   in caif's setsockopt,  using the struct sock attribute priority ins=
tead.
>=20
> o Bugfix: SO_BINDTODEVICE for SOL_SOCKET could not be handled
>   in caif's setsockopt,  using the struct sock attribute ifindex inst=
ead.
>=20
> o Wrong assert statement for RFM layer segmentation.
>=20
> o CAIF Debug channels was not working over SPI, caif_payload_info
>   containing padding info must be initialized.
>=20
> o Check on pointer before dereferencing when unregister dev in caif_d=
ev.c
>=20
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
