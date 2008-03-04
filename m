From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Remove usage of C++ keyword 'class' on htb.h header.
Date: Tue, 4 Mar 2008 12:53:32 -0800
Message-ID: <20080304125332.7e4d3b3c.randy.dunlap@oracle.com>
References: <1204655476-2663-1-git-send-email-rmatos@av.it.pt>
	<1204655476-2663-2-git-send-email-rmatos@av.it.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: Rui Tiago =?ISO-8859-1?Q?Ca=E7=E3o?= Matos <rmatos@av.it.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:60441 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325AbYCDUzJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 15:55:09 -0500
In-Reply-To: <1204655476-2663-2-git-send-email-rmatos@av.it.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Mar 2008 18:31:16 +0000 Rui Tiago Ca=E7=E3o Matos wrote:

> Signed-off-by: Rui Tiago Ca=E7=E3o Matos <rmatos@av.it.pt>
> ---
>  include/netlink/route/sch/htb.h |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/netlink/route/sch/htb.h b/include/netlink/route/=
sch/htb.h
> index 5d4d681..d44f039 100644
> --- a/include/netlink/route/sch/htb.h
> +++ b/include/netlink/route/sch/htb.h
> @@ -30,9 +30,9 @@ extern void rtnl_htb_set_rate(struct rtnl_class *, =
uint32_t);
>  extern void rtnl_htb_set_ceil(struct rtnl_class *, uint32_t);
>  extern void rtnl_htb_set_rbuffer(struct rtnl_class *, uint32_t);
>  extern void rtnl_htb_set_cbuffer(struct rtnl_class *, uint32_t);
> -extern void rtnl_htb_set_quantum(struct rtnl_class *class, uint32_t =
quantum);
> -extern void rtnl_htb_set_overhead(struct rtnl_class *class, uint8_t =
overhead);
> -extern void rtnl_htb_set_mpu(struct rtnl_class *class, uint8_t mpu);
> +extern void rtnl_htb_set_quantum(struct rtnl_class *, uint32_t quant=
um);
> +extern void rtnl_htb_set_overhead(struct rtnl_class *, uint8_t overh=
ead);
> +extern void rtnl_htb_set_mpu(struct rtnl_class *, uint8_t mpu);
> =20
>  #ifdef __cplusplus
>  }


We generally prefer to see function parameter names present in prototyp=
es.

What about the other 30 or so C++ keywords that the kernel uses?
Do you have a metric ton of more patches?

---
~Randy
