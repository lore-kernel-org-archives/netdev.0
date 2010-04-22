From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Wed, 21 Apr 2010 23:18:43 -0700
Message-ID: <20100421231843.4c284991@nehalam>
References: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42188 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab0DVGTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 02:19:01 -0400
In-Reply-To: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Apr 2010 13:51:53 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> +	struct sk_buff		*input_pkt_queue_head;
> +	struct sk_buff		**input_pkt_queue_tailp;
> +	unsigned int		input_pkt_queue_len;
> +	unsigned int		process_queue_len;

Why is opencoding a skb queue a step forward?
Just keep using sk_queue routines, just not the locked variants.

-- 
