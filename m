From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/10] ipv4: make fib_detect_death static
Date: Tue, 17 Dec 2013 17:20:22 -0500 (EST)
Message-ID: <20131217.172022.2203704909606435914.davem@davemloft.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab3LQWUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:20:24 -0500
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 16 Dec 2013 10:36:06 -0800

> @@ -426,7 +426,7 @@ struct fib_alias *fib_find_alias(struct
>  	return NULL;
>  }
>  
> -int fib_detect_death(struct fib_info *fi, int order,
> +static int fib_detect_death(struct fib_info *fi, int order,
>  		     struct fib_info **last_resort, int *last_idx, int dflt)

Please update the argument indentation when you add the static
tag like this, I see you did this properly elsewhere in this
series.
