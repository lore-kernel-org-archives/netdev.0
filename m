From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [PATCH] gianfar: Update Marvell PHY name
Date: Thu, 10 Mar 2005 01:30:02 -0600
Message-ID: <1047a05d13208f6f49df5590040d3c16@freescale.com>
References: <Pine.LNX.4.61.0503040150480.16127@blarg.somerset.sps.mot.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: inuxppc-embedded List <linuxppc-embedded@ozlabs.org>,
        Netdev <netdev@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.61.0503040150480.16127@blarg.somerset.sps.mot.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Just wondering if this got lost?  Might be moot depending what=20
likelihood of getting Andy's PHY Abstraction Layer changes into the=20
kernel.

- kumar

On Mar 4, 2005, at 1:55 AM, Kumar Gala wrote:

> Jeff,
>
> This patch updates the name identifier to list both of the Marvell PHYs
> that are supported.
>
> Signed-off-by: Kumar Gala <kumar.gala@freescale.com>
>
> ---
>  diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
> --- a/drivers/net/gianfar_phy.c 2005-03-02 14:20:27 -06:00
>  +++ b/drivers/net/gianfar_phy.c 2005-03-02 14:20:27 -06:00
>  @@ -572,7 +572,7 @@
>  =A0static struct phy_info phy_info_marvell =3D {
>  =A0=A0=A0=A0=A0=A0=A0 .phy_id =A0=A0=A0=A0=A0=A0=A0 =3D 0x01410c00,
>  =A0=A0=A0=A0=A0=A0=A0 .phy_id_mask=A0=A0=A0 =3D 0xffffff00,
>  -=A0=A0=A0=A0=A0=A0 .name=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D "Marvell 88E=
1101",
>  +=A0=A0=A0=A0=A0=A0 .name=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D "Marvell 88E=
1101/88E1111",
> =A0=A0=A0=A0=A0=A0=A0 .features=A0=A0=A0=A0=A0=A0 =3D MII_GBIT_FEATURES=
,
> =A0=A0=A0=A0=A0=A0=A0 .config_aneg=A0=A0=A0 =3D &marvell_config_aneg,
> =A0=A0=A0=A0=A0=A0=A0 .read_status=A0=A0=A0 =3D &marvell_read_status,
> _______________________________________________
> Linuxppc-embedded mailing list
>  Linuxppc-embedded@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-embedded
