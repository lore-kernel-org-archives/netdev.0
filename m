From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH] Add another Prism2 card to hostap
Date: Wed, 30 Jan 2008 16:15:34 -0500
Message-ID: <1201727734.8103.18.camel@dv>
References: <200801290942.56258.openembedded@haerwu.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jouni Malinen <j@w1.fi>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200801290942.56258.openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tue, 2008-01-29 at 09:42 +0100, Marcin Juszkiewicz wrote:
> From: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>
>=20
> Card reported by =C5ngstr=F6m user:
> http://bugs.openembedded.net/show_bug.cgi?id=3D3236
>=20
> Socket 1:
>    product info: "Wireless LAN", "11Mbps PC Card", "Version 01.02", "=
"
>    manfid: 0x0156, 0x0002
>    function: 6 (network)
>=20
> Signed-off-by: Marcin Juszkiewicz <openembedded-sbG99h22wavzs492ZWNkEA@public.gmane.org>

Acked-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

> diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wi=
reless/hostap/hostap_cs.c
> index 877d3bd..4f6707c 100644
> --- a/drivers/net/wireless/hostap/hostap_cs.c
> +++ b/drivers/net/wireless/hostap/hostap_cs.c
> @@ -894,6 +894,9 @@ static struct pcmcia_device_id hostap_cs_ids[] =3D=
 {
>                 "The Linksys Group, Inc.", "Wireless Network CF Card"=
, "ISL37300P",
>                 "RevA",
>                 0xa5f472c2, 0x9c05598d, 0xc9049a39, 0x57a66194),
> +       PCMCIA_DEVICE_PROD_ID123(
> +           "Wireless LAN" , "11Mbps PC Card", "Version 01.02",
> +               0x4b8870ff, 0x70e946d1, 0x4b74baa0),
>         PCMCIA_DEVICE_NULL
>  };
>  MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
>=20
--=20
Regards,
Pavel Roskin
