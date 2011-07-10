From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slip: fix wrong SLIP6 ifdef-endif placing
Date: Sun, 10 Jul 2011 11:37:41 -0700 (PDT)
Message-ID: <20110710.113741.2147626275846755476.davem@davemloft.net>
References: <CAKh5nabf9OBG7yb5r=v0bhJLjNJgVrw-hVx9quJ9cwcOXSva=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756450Ab1GJShs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 14:37:48 -0400
In-Reply-To: <CAKh5nabf9OBG7yb5r=v0bhJLjNJgVrw-hVx9quJ9cwcOXSva=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Sun, 10 Jul 2011 22:32:55 +0400

> SLIP6 have nothing to do with CSLIP so placing a block of
> SLIP6-related code within a CSLIP ifdef-endif block is incorrect.
> 
> Signed-off-by: Ilya Matvejchikov <matvejchikov@gmail.com>
 ...
> @@ -194,8 +194,7 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
>  err_exit:
>  #ifdef SL_INCLUDE_CSLIP
>  	kfree(cbuff);
> -	if (slcomp)
> -		slhc_free(slcomp);
> +	slhc_free(slcomp);
>  #endif

The change in this hunk has nothing to do with what you
claim to be doing in your commit message.

Don't mix unrelated changes together.
