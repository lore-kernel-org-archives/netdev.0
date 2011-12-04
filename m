From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH net-next V0 03/21] mlx4_core: Add "native" argument to
 mlx4_cmd and its callers (where needed)
Date: Sun, 4 Dec 2011 10:43:51 +0000
Message-ID: <953B660C027164448AE903364AC447D22362736D@MTLDAG01.mtl.com>
References: <4ED8A591.2070705@mellanox.co.il>
 <CAL1RGDXh0-v075fdxvoA=sL0vOq1ncouNNH5v3y7QFHJmnnQEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDXh0-v075fdxvoA=sL0vOq1ncouNNH5v3y7QFHJmnnQEA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > =A0 =A0 =A0 =A0return mlx4_cmd(dev, limit_watermark, srq_num, 0, ML=
X4_CMD_ARM_SRQ,
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_CMD_TIME_CLASS_B=
);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_CMD_TIME_CLASS_B=
, 0);
>=20
> Instead of a 0 or 1 for the native parameter, can we define something=
 like
>=20
> enum {
>            MLX4_CMD_NATIVE,
>            MLX4_CMD_WRAPPED
> };
>=20
> so that all these calls become easier to read?
=20
Agree,
We will change this for next round.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
