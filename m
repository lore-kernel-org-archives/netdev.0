From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Tue, 16 Apr 2013 12:36:53 -0300
Message-ID: <CAOMZO5AJt1aLMheqsR_BEpHeGzOTOgrMdjAQFbAY7RmSdOfPoA@mail.gmail.com>
References: <1366107927-3642-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f48.google.com ([209.85.212.48]:48463 "EHLO
	mail-vb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935661Ab3DPPgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 11:36:54 -0400
Received: by mail-vb0-f48.google.com with SMTP id p13so475599vbe.21
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 08:36:53 -0700 (PDT)
In-Reply-To: <1366107927-3642-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 7:25 AM, Jim Baxter <jim_baxter@mentor.com> wrote:
> Enables hardware generatation of IP header and

generation


> +/* FEC receive accleration */

acceleration

...

>  static netdev_tx_t
>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  {
> @@ -277,6 +333,9 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>         bufaddr = skb->data;
>         bdp->cbd_datlen = skb->len;
>
> +       /* HW accleration for ICMP TCP UDP checksum */

acceleration
