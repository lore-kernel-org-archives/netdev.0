From: Michael Trimarchi <michael@amarulasolutions.com>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Fri, 11 Mar 2016 13:12:03 +0100
Message-ID: <CAOf5uwkzYBuRty7UfAOwZaAeqYqFboR=yvu7izh9vRw7e+RE5A@mail.gmail.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
	<56DD7172.4000707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
	netdev@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Heiko Stuebner <heiko@sntech.de>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: =?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34418 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbcCKMMF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 07:12:05 -0500
Received: by mail-ig0-f178.google.com with SMTP id av4so9776463igc.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 04:12:03 -0800 (PST)
In-Reply-To: <56DD7172.4000707@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Mon, Mar 7, 2016 at 1:17 PM, Andreas F=C3=A4rber <afaerber@suse.de> =
wrote:
> Am 06.03.2016 um 20:53 schrieb Andreas F=C3=A4rber:
>> On next-20160304 the GMAC seems to have regressed, it no longer find=
s the PHY:
>>
>> libphy: PHY stmmac-0:ffffffff not found
>> eth0: Could not attach to PHY
>> stmmac_open: Cannot attach to PHY (error: -19)
>
> Still with us in next-20160307. CC'ing stmmac maintainers.
>

        tx_delay =3D <0x30>;
        rx_delay =3D <0x10>;
        status =3D "ok";
+       mdio0 {
+               #address-cells =3D <1>;
+               #size-cells =3D <0>;
+               compatible =3D "snps,dwmac-mdio";
+               ethphy0: ethernet-phy@0 {
+               };
+       };

This is sufficient to get it in the rk3288 firefly

git://git.kernel.org/pub/scm/linux/kernel/git/mmind/linux-rockchip.git =
for-next

Michael

> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/d=
rivers/net/ethernet/stmicro
>
> Regards,
> Andreas
>
> --
> SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg, Germany
> GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton; HRB 21284 (=
AG N=C3=BCrnberg)
>
> _______________________________________________
> Linux-rockchip mailing list
> Linux-rockchip@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-rockchip



--=20
| Michael Nazzareno Trimarchi                     Amarula Solutions BV =
|
| COO  -  Founder                                      Cruquiuskade 47 =
|
| +31(0)851119172                                 Amsterdam 1018 AM NL =
|
|                  [`as] http://www.amarulasolutions.com               =
|
