From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] net: Add skb_get_hash_raw
Date: Wed, 15 Jan 2014 09:15:17 -0800
Message-ID: <1389806117.31367.349.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401150853090.14881@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39464 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbaAORPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 12:15:20 -0500
Received: by mail-pd0-f180.google.com with SMTP id x10so63689pdj.25
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 09:15:19 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1401150853090.14881@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 08:57 -0800, Tom Herbert wrote:
> Function to just return skb->rxhash without checking to see if it needs
> to be recomputed.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/skbuff.h | 5 +++++
>  1 file changed, 5 insertions(+)

Acked-by: Eric Dumazet <edumazet@google.com>
