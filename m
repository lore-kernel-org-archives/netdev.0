From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: drivers/net/phy/dp83867.c:167: possible bad if ?
Date: Mon, 20 Jul 2015 10:28:38 -0700
Message-ID: <55AD2FC6.60508@gmail.com>
References: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Binderman <dcb314@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, dmurphy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34831 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756431AbbGTRac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 13:30:32 -0400
Received: by pabkd10 with SMTP id kd10so32352822pab.2
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 10:30:32 -0700 (PDT)
In-Reply-To: <DUB128-W6216BE4A8E21E94EEB06DE9C850@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding Dan,

On 20/07/15 05:37, David Binderman wrote:
> Hello there,
>=20
> drivers/net/phy/dp83867.c:167:57: warning: logical =E2=80=98or=E2=80=99=
 of collectively exhaustive tests is always true [-Wlogical-op]
>=20
> Source code is
>=20
>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) ||
>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
>=20
> Maybe
>=20
>     if ((phydev->interface>=3D PHY_INTERFACE_MODE_RGMII_ID) &&
>         (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {

Sounds like the former is the intended comparison that will make sure
that phydev->interface is between MODE_RGMII_ID and MODE_RGMII_RXID, an=
d
not below or after.
--=20
=46lorian
