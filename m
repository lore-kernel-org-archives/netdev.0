From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 05:26:11 -0700
Message-ID: <1413203171.9362.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?ISO-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:65197 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbaJMM0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 08:26:14 -0400
In-Reply-To: <20141013105246.GD1972@vicerveza.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-13 at 12:52 +0200, Llu=C3=ADs Batlle i Rossell wrote:
> Hello,
>=20
> on the 7th of January 2014 ths patch was applied:
> https://lkml.org/lkml/2014/1/7/307
>=20
> [PATCH v2] net: Do not enable tx-nocache-copy by default
>        =20
> In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made packe=
ts to be
> sent corrupted. I think this machine has something special about the =
cache.
>=20
> Enabling back this tx-nocache-copy (as it used to be before the patch=
) the
> transfers work fine again. I think that most people, encountering thi=
s problem,
> completely disable the tx offload instead of enabling back this setti=
ng.
>=20
> Is this an ARM kernel problem regarding this platform?

Which NIC and driver is this exactly ?
