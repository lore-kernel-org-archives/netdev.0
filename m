From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [PATCH 02/11] enic: remove unnecessary setting of skb->dev
Date: Thu, 12 Jul 2012 14:19:16 -0700
Message-ID: <CAPoiz9y2D15o4ueTCWPQHiNHexBVXSABO_1ghpKtYCruSDV-Ew@mail.gmail.com>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
	<1341878975-10577-2-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39284 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934248Ab2GLVTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 17:19:18 -0400
Received: by bkwj10 with SMTP id j10so2639057bkw.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 14:19:16 -0700 (PDT)
In-Reply-To: <1341878975-10577-2-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 9, 2012 at 5:09 PM, Jon Mason <jdmason@kudzu.us> wrote:
> skb->dev is being unnecessarily set after calling eth_type_trans.
> eth_type_trans already sets skb->dev to the proper value, thus making this
> unnecessary.
>
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> Cc: Christian Benvenuti <benve@cisco.com>
> Cc: Roopa Prabhu <roprabhu@cisco.com>

This address bounced.  Anyone know of an updated address for Roopa or
should they be removed from the MAINTAINERS list?

> Cc: Neel Patel <neepatel@cisco.com>
> Cc: Nishank Trivedi <nistrive@cisco.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 8132c78..ad1468b 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -1300,8 +1300,6 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>                         skb->ip_summed = CHECKSUM_COMPLETE;
>                 }
>
> -               skb->dev = netdev;
> -
>                 if (vlan_stripped)
>                         __vlan_hwaccel_put_tag(skb, vlan_tci);
>
> --
> 1.7.9.5
>
