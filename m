From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net/fs_enet/mii-fec: Use PHY_POLL instead of hard coded
	'-1'
Date: Fri, 8 May 2009 09:55:31 -0600
Message-ID: <fa686aa40905080855g1b24b9f4s7a78ccb75b5be8b1@mail.gmail.com>
References: <1241791201-23960-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vitaly Bordug <vbordug@ru.mvista.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:1771 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbZEHPzu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 11:55:50 -0400
Received: by yx-out-2324.google.com with SMTP id 3so879600yxj.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2009 08:55:51 -0700 (PDT)
In-Reply-To: <1241791201-23960-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2009 at 8:00 AM, Wolfram Sang <w.sang@pengutronix.de> wr=
ote:
> Initialize the irq-table with PHY_POLL. '-1' means the same now, but =
is
> hardly maintainable.
>
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Vitaly Bordug <vbordug@ru.mvista.com>
> Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: netdev@vger.kernel.org
> Cc: linuxppc-dev@ozlabs.org
> ---
> =A0drivers/net/fs_enet/mii-fec.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-=
fec.c
> index 28077cc..9eb5480 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -166,7 +166,7 @@ static int __devinit fs_enet_mdio_probe(struct of=
_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unmap_regs;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < PHY_MAX_ADDR; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[i] =3D -1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus->irq[i] =3D PHY_POLL;

This code no longer exists in net-next.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
