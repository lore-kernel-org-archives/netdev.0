From: Xing Zheng <zhengxing@rock-chips.com>
Subject: Re: [RESEND PATCH v1 3/4] net: ethernet: arc: Add support emac for RK3036
Date: Sat, 2 Jan 2016 10:38:28 +0800
Message-ID: <6ADB598D-07E0-4E51-A9FE-25B47FD87F7E@rock-chips.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com> <1451287341-16453-4-git-send-email-zhengxing@rock-chips.com> <FFCE9129-357E-4643-A350-9927A5AD5720@gmail.com> <3169681.aSJgN2TRic@wuerfel>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-rockchip@lists.infradead.org, heiko@sntech.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>, keescook@google.com,
	leozwang@google.com, davem@davemloft.net, xing.zheng@rock-chips.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3169681.aSJgN2TRic@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



OK, I think I will use named structures.

Thanks.

> =D4=DA 2016=C4=EA1=D4=C21=C8=D5=A3=AC20:55=A3=ACArnd Bergmann <arnd@a=
rndb.de> =D0=B4=B5=C0=A3=BA
>=20
>> On Tuesday 29 December 2015 14:59:59 Florian Fainelli wrote:
>>> On December 27, 2015 11:22:20 PM PST, Xing Zheng <zhengxing@rock-ch=
ips.com> wrote:
>>> The RK3036's GRFs offset are different with RK3066/RK3188, and need=
 to
>>> set
>>> mac TX/RX clock before probe emac.
>>>=20
>>> Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
>>> ---
>> <snip>
>>> };
>>>=20
>>> static const struct of_device_id emac_rockchip_dt_ids[] =3D {
>>> -      { .compatible =3D "rockchip,rk3066-emac", .data =3D
>>> &emac_rockchip_dt_data[0] },
>>> -      { .compatible =3D "rockchip,rk3188-emac", .data =3D
>>> &emac_rockchip_dt_data[1] },
>>> +      { .compatible =3D "rockchip,rk3036-emac", .data =3D
>>> &emac_rockchip_dt_data[0] },
>>> +      { .compatible =3D "rockchip,rk3066-emac", .data =3D
>>> &emac_rockchip_dt_data[1] },
>>> +      { .compatible =3D "rockchip,rk3188-emac", .data =3D
>>> &emac_rockchip_dt_data[2] },
>>>      { /* Sentinel */ }
>>=20
>> Food for thought, you might want to use an enum here to index emac_r=
ockchip_dt_data which would be less error prone if you add/remove entri=
es in this structure.
>=20
> I would use named structures instead:
>=20
> static const struct emac_rockchip_soc_data emac_rk3066_emac_data =3D =
{
>    .grf_offset =3D 0x154,
> };
>=20
> static const struct of_device_id emac_rockchip_dt_ids[] =3D {
>    { .compatible =3D "rockchip,rk3066-emac", .data =3D &emac_rk3066_e=
mac_data,
>    ...
> };
>=20
>    Armd
>=20
>=20
