From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iwl3945: better skb management in rx path
Date: Fri, 28 Jun 2013 07:59:49 -0700
Message-ID: <1372431589.3301.280.camel@edumazet-glaptop>
References: <1372421021.3301.263.camel@edumazet-glaptop>
	 <CAMcMvshEdsFZ2PVEpaq0e2P4L+cksshjB56x2YvA4wt3T+3__w@mail.gmail.com>
	 <1372431024.3301.277.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Steinar H. Gunderson" <sesse@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Paul Stewart <pstew@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42868 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948Ab3F1O7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 10:59:51 -0400
In-Reply-To: <1372431024.3301.277.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 07:50 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

> +	if (len <= SMALL_PACKET_SIZE) {
> +		skb_copy_to_linear_data(skb, rx_hdr->payload, len);
> +		skb->tail += len;
> +	} else {

Hmm I'll send a v3, we need a regular __skb_put() here
