From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/6] net: use lib/percpu_counter API for
 fragmentation mem accounting
Date: Mon, 28 Jan 2013 23:24:02 -0500 (EST)
Message-ID: <20130128.232402.883917994065372213.davem@davemloft.net>
References: <20130124140343.14119.77712.stgit@dragon>
	<20130124140441.14119.1878.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, amwang@redhat.com, kaber@trash.net,
	herbert@gondor.hengli.com.au, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab3A2EYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:24:04 -0500
In-Reply-To: <20130124140441.14119.1878.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 24 Jan 2013 15:04:53 +0100

> diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> index b9df9ed..eded1aa 100644
> --- a/include/linux/percpu_counter.h
> +++ b/include/linux/percpu_counter.h
> @@ -83,7 +83,7 @@ static inline int percpu_counter_initialized(struct percpu_counter *fbc)
>  	return (fbc->counters != NULL);
>  }
>  
> -#else
> +#else /* No CONFIG_SMP */
>  
>  struct percpu_counter {
>  	s64 count;

This is unrelated to your changes, please remove this from the patch.
