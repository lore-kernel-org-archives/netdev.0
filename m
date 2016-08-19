From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] rhashtable: Remove GFP flag from rhashtable_walk_init
Date: Fri, 19 Aug 2016 18:25:04 +0200
Message-ID: <20160819162504.GA29430@pox.localdomain>
References: <20160818084854.GA11502@gondor.apana.org.au>
 <E1baJ2O-00030u-FE@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38441 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbcHSQZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 12:25:26 -0400
Received: by mail-wm0-f54.google.com with SMTP id o80so48640654wme.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 09:25:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1baJ2O-00030u-FE@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/16 at 04:50pm, Herbert Xu wrote:
> +/* Obsolete function, do not use in new code. */
> +static inline int rhashtable_walk_init(struct rhashtable *ht,
> +				       struct rhashtable_iter *iter, gfp_t gfp)
> +{
> +	rhashtable_walk_enter(ht, iter);
> +	return 0;
> +}

Converting the 5 users of rhashtable_walk_init() looks very straight
forward, any reason to keep this around?
