From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 3/3] net: Add GRO support for vxlan traffic
Date: Wed, 08 Jan 2014 14:09:37 -0800
Message-ID: <1389218977.31367.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
	 <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:51350 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbaAHWJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 17:09:28 -0500
Received: by mail-pa0-f41.google.com with SMTP id fb1so859391pad.14
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 14:09:27 -0800 (PST)
In-Reply-To: <1389213278-2200-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 22:34 +0200, Or Gerlitz wrote:
> +
> +static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
> +{
> +	struct ethhdr *eh;
> +	struct packet_offload *ptype;
> +	__be16 type;
> +	/* 22 = 8 bytes for the vlxan header + 14 bytes for the inner eth header */
> +	int vxlan_len  = 22;



I am pretty sure this can use existing macros or sizeof(...)
