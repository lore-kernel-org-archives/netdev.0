From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 3/7] fou: Add GRO support
Date: Mon, 15 Sep 2014 14:22:27 -0400 (EDT)
Message-ID: <20140915.142227.385081853295017602.davem@davemloft.net>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329AbaIOSWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:22:30 -0400
In-Reply-To: <1410750483-3236-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 14 Sep 2014 20:07:59 -0700

> @@ -62,6 +64,70 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
>  					  sizeof(struct udphdr));
>  }
>  
> +static inline struct sk_buff **fou_gro_receive(struct sk_buff **head,
> +					       struct sk_buff *skb,
> +					       const struct net_offload
> +							     **offloads)

Please drop the "inline" in foo.c files and let the compiler decide.  And
then you won't need to split up the "offloads" variable declaration like
that.
