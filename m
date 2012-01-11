From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [PATCH 02/21] bfin_mac: use an unique MDIO bus name.
Date: Wed, 11 Jan 2012 22:47:31 +0800
Message-ID: <CAA_GA1fJAsjmcZ6ixoMajut0U1V+gNewFqDkhdOjS8Btd-4O3Q@mail.gmail.com>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
	<1326189567-21663-3-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326189567-21663-3-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2012 at 5:59 PM, Florian Fainelli <florian@openwrt.org>=
 wrote:
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> =C2=A0drivers/net/ethernet/adi/bfin_mac.c | =C2=A0 =C2=A03 ++-
> =C2=A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethern=
et/adi/bfin_mac.c
> index b6d69c9..d812a10 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -1670,7 +1670,8 @@ static int __devinit bfin_mii_bus_probe(struct =
platform_device *pdev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0miibus->name =3D "bfin_mii_bus";
> =C2=A0 =C2=A0 =C2=A0 =C2=A0miibus->phy_mask =3D mii_bus_pd->phy_mask;
>
> - =C2=A0 =C2=A0 =C2=A0 snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
> + =C2=A0 =C2=A0 =C2=A0 snprintf(miibus->id, MII_BUS_ID_SIZE, "%s-%x",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pdev->name, pdev->=
id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0miibus->irq =3D kmalloc(sizeof(int)*PHY_MA=
X_ADDR, GFP_KERNEL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!miibus->irq)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_err_i=
rq_alloc;
> --
> 1.7.5.4

Looks fine for me.  Thanks.

Acked-by: Bob Liu <lliubbo@gmail.com>

--=20
Regards,
--Bob
