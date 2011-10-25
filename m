From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Tue, 25 Oct 2011 11:08:08 -0200
Message-ID: <20111025110808.27db8487@asterix.rh>
References: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
	<1319519056-21677-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <maze@google.com>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933213Ab1JYNIN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 09:08:13 -0400
In-Reply-To: <1319519056-21677-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Oct 2011 22:04:16 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  drivers/net/bonding/bond_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c index 41430ba..2cbc2f8 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -395,7 +395,6 @@ int bond_dev_queue_xmit(struct bonding *bond,
> struct sk_buff *skb, struct net_device *slave_dev)
>  {
>  	skb->dev =3D slave_dev;
> -	skb->priority =3D 1;
> =20
>  	skb->queue_mapping =3D bond_queue_mapping(skb);
> =20

I tripped on it few times and never understood why we
were fixing the priority at this point.
thanks,

Acked-by: Flavio Leitner <fbl@redhat.com>
=20
