From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 3/4] netfilter: Pass socket pointer down through okfn().
Date: Tue, 07 Apr 2015 16:44:29 +0200
Message-ID: <1428417869.2928.1.camel@stressinduktion.org>
References: <20150405.221904.606225054570296194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58588 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752902AbbDGOoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 10:44:32 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id EDEEE20AE4
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 10:44:27 -0400 (EDT)
In-Reply-To: <20150405.221904.606225054570296194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On So, 2015-04-05 at 22:19 -0400, David Miller wrote:
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -54,7 +54,7 @@ struct nf_hook_state {
>  	struct net_device *in;
>  	struct net_device *out;
>  	struct sock *sk;
> -	int (*okfn)(struct sk_buff *);
> +	int (*okfn)(struct sock *, struct sk_buff *);
>  };

If we give okfn the signature int (*okfn)(struct nf_hook_state *); then
we would not need to touch anything else to enhance this.

What do you think?

Thanks,
Hannes
