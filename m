From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 05/11] net: Add full IPv6 addresses to
 flow_keys
Date: Thu, 28 May 2015 14:44:56 -0700
Message-ID: <1432849496.7456.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
	 <1432837148-1359931-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37128 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779AbbE1Vo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 17:44:59 -0400
Received: by igbsb11 with SMTP id sb11so207229igb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 14:44:58 -0700 (PDT)
In-Reply-To: <1432837148-1359931-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 11:19 -0700, Tom Herbert wrote:

> @@ -566,11 +640,15 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
>  	},
>  	{
>  		.key_id = FLOW_DISSECTOR_KEY_IPV4_ADDRS,
> -		.offset = offsetof(struct flow_keys, addrs),
> +		.offset = offsetof(struct flow_keys, addrs.v4addrs),
> +	},
> +	{
> +		.key_id = FLOW_DISSECTOR_KEY_IPV6_ADDRS,
> +		.offset = offsetof(struct flow_keys, addrs.v6addrs),
>  	},
>  	{
>  		.key_id = FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
> -		.offset = offsetof(struct flow_keys, addrs),
> +		.offset = offsetof(struct flow_keys, addrs.v4addrs),

Shouldn't it be offsetof(struct flow_keys, addrs.v6addrs), ?
