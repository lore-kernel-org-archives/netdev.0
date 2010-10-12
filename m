From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
 enablement
Date: Tue, 12 Oct 2010 21:18:49 +0200
Message-ID: <1286911129.2703.7.camel@edumazet-laptop>
References: <1286910141.16797.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, vladz@broadcom.com,
	eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39698 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758039Ab0JLTTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 15:19:10 -0400
Received: by wwj40 with SMTP id 40so5478717wwj.1
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 12:19:08 -0700 (PDT)
In-Reply-To: <1286910141.16797.23.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 21:02 +0200, Dmitry Kravkov a =C3=A9cri=
t :
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> ---
>  drivers/net/bnx2x/bnx2x_main.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x=
_main.c
> index 7a9556b..ead524b 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -2486,6 +2486,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
>  	 * if (is_eth_multi(bp))
>  	 *	flags |=3D FUNC_FLG_RSS;
>  	 */
> +	flags |=3D FUNC_FLG_RSS;
> =20
>  	/* function setup */
>  	if (flags & FUNC_FLG_RSS) {

Thanks, this solved the problem.

Tested-by: Eric Dumazet <eric.dumazet@gmail.com>


