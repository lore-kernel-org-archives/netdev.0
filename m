From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH net-next V0 03/21] mlx4_core: Add "native" argument to
 mlx4_cmd and its callers (where needed)
Date: Fri, 2 Dec 2011 09:01:00 -0800
Message-ID: <CAL1RGDXh0-v075fdxvoA=sL0vOq1ncouNNH5v3y7QFHJmnnQEA@mail.gmail.com>
References: <4ED8A591.2070705@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED8A591.2070705-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 2, 2011 at 2:16 AM, Yevgeny Petrilin
<yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> wrote:
> =A0 =A0 =A0 =A0return mlx4_cmd(dev, limit_watermark, srq_num, 0, MLX4=
_CMD_ARM_SRQ,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_CMD_TIME_CLASS_B);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MLX4_CMD_TIME_CLASS_B, =
0);

Instead of a 0 or 1 for the native parameter, can we define something l=
ike

enum {
           MLX4_CMD_NATIVE,
           MLX4_CMD_WRAPPED
};

so that all these calls become easier to read?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
