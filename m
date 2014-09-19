From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/8] net: phy: Broadcom BCM7xxx PHY workaround
 update
Date: Fri, 19 Sep 2014 12:59:11 -0700
Message-ID: <541C8B0F.9050109@gmail.com>
References: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>	<20140919.154104.286842667424203847.davem@davemloft.net> <20140919.155554.871635845344096230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63133 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbaIST70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 15:59:26 -0400
Received: by mail-pd0-f180.google.com with SMTP id r10so556238pdi.11
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 12:59:25 -0700 (PDT)
In-Reply-To: <20140919.155554.871635845344096230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 12:55 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 19 Sep 2014 15:41:04 -0400 (EDT)
>=20
>> Series applied, thanks Florian.
>=20
> Actually I had to revert:
>=20
> net/dsa/slave.c: In function =E2=80=98dsa_slave_phy_setup=E2=80=99:
> net/dsa/slave.c:395:42: error: =E2=80=98port=E2=80=99 undeclared (fir=
st use in this function)
>    phy_flags =3D ds->drv->get_phy_flags(ds, port);
>                                           ^
> net/dsa/slave.c:395:42: note: each undeclared identifier is reported =
only once for each function it appears in
>=20

Whoops, I will fix that immediately.
