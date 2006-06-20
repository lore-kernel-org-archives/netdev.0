From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [2/5] [NET]: Add generic segmentation offload
Date: Tue, 20 Jun 2006 10:54:48 -0700
Message-ID: <1150826089.17133.14.camel@rh4>
References: <20060620090919.GA31613@gondor.apana.org.au>
 <20060620092840.GB31854@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:64005 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750750AbWFTR4Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 13:56:25 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060620092840.GB31854@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-20 at 19:28 +1000, Herbert Xu wrote:

> [NET]: Add generic segmentation offload
> 
> +static int dev_gso_segment(struct sk_buff *skb)
> +{
> +       struct sk_buff *segs;
> +
> +       segs = skb_gso_segment(skb, skb->dev->features & NETIF_F_SG &&
> +                                   !illegal_highdma(dev, skb));

I think you need !illegal_highdma(skb->dev, skb)

