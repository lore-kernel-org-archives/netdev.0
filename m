From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 2/5] net: tcp: add flag for ca to indicate
 that ECN is required
Date: Mon, 22 Sep 2014 09:26:06 -0700
Message-ID: <20140922092606.10977e48@urahara>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
	<1411248562-26581-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hagen@jauu.net, lars@netapp.com,
	eric.dumazet@gmail.com, fontana@sharpeleven.org,
	hannes@stressinduktion.org, glenn.judd@morganstanley.com,
	dborkman@redhat.com, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:63041 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbaIVQ0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:26:17 -0400
Received: by mail-pa0-f51.google.com with SMTP id eu11so3139039pac.10
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 09:26:16 -0700 (PDT)
In-Reply-To: <1411248562-26581-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2014 23:29:19 +0200
Florian Westphal <fw@strlen.de> wrote:

> +static inline void
> +TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
> +		       const struct sock *listen_sk)

Maybe good time to switch to lower case here for function name.
