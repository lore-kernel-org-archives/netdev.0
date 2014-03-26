From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: Proper printf format for ptrdiff_t is 't'.
Date: Wed, 26 Mar 2014 09:50:58 +0000
Message-ID: <1395827458.22808.16.camel@kazak.uk.xensource.com>
References: <20140325.190330.1170650394087694357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50928 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbaCZJvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 05:51:00 -0400
In-Reply-To: <20140325.190330.1170650394087694357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-25 at 19:03 -0400, David Miller wrote:
> This fixes:
>=20
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_dea=
lloc_action=E2=80=99:
> drivers/net/xen-netback/netback.c:1573:8: warning: format =E2=80=98%x=
=E2=80=99 expects argument of type =E2=80=98unsigned int=E2=80=99, but =
argument 3 has type =E2=80=98long int=E2=80=99 [-Wformat=3D]
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> Committed to net-next, this has been bugging me for weeks.

Oops sorry. Ack to the patch FWIW.

Ian.
