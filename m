From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [PATCH] atlx: duplicate testing of MCAST flag
Date: Sun, 12 Jul 2009 19:04:20 -0500
Message-ID: <3400f2f60907121704s105ba16bqebcdb75bc855888e@mail.gmail.com>
References: <4A5A6DE5.4090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: atl1-devel@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:34304 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbZGMAEX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 20:04:23 -0400
Received: by yxe14 with SMTP id 14so2597304yxe.33
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 17:04:20 -0700 (PDT)
In-Reply-To: <4A5A6DE5.4090801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 12, 2009 at 6:12 PM, Roel Kluin<roel.kluin@gmail.com> wrote=
:
> Fix duplicate testing of MCAST flag
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> I think the first should be UCAST, correct?
>
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index c734b19..204db96 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -2071,7 +2071,7 @@ static int atl2_set_wol(struct net_device *netd=
ev, struct ethtool_wolinfo *wol)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (wol->wolopts & (WAKE_ARP | WAKE_MAGICS=
ECURE))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EOPNOT=
SUPP;
>
> - =C2=A0 =C2=A0 =C2=A0 if (wol->wolopts & (WAKE_MCAST|WAKE_BCAST|WAKE=
_MCAST))
> + =C2=A0 =C2=A0 =C2=A0 if (wol->wolopts & (WAKE_UCAST | WAKE_BCAST | =
WAKE_MCAST))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EOPNOT=
SUPP;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* these settings will always override wha=
t we currently have */
>

Acked-by: Jay Cliburn <jcliburn@gmail.com>
