From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Mon, 30 Mar 2009 18:59:26 +0200
Message-ID: <49D0FA6E.4090402@gmail.com>
References: <20090330085302.19172.22808.stgit@localhost.localdomain> <20090330090306.19172.94170.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:61318 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbZC3RAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 13:00:50 -0400
Received: by ti-out-0910.google.com with SMTP id i7so1759135tid.23
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 10:00:46 -0700 (PDT)
In-Reply-To: <20090330090306.19172.94170.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote, On 03/30/2009 11:03 AM:

> Trival spelling fixes in RCU/rculist_nulls.txt.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
> 
>  Documentation/RCU/rculist_nulls.txt |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
> index 239f542..ba075b2 100644
> --- a/Documentation/RCU/rculist_nulls.txt
> +++ b/Documentation/RCU/rculist_nulls.txt
> @@ -21,7 +21,7 @@ if (obj) {
>    /*
>     * Because a writer could delete object, and a writer could
>     * reuse these object before the RCU grace period, we
> -   * must check key after geting the reference on object
> +   * must check key after getting the reference on object
>     */
>    if (obj->key != key) { // not the object we expected
>       put_ref(obj);
> @@ -117,7 +117,7 @@ a race (some writer did a delete and/or a move of an object
>  to another chain) checking the final 'nulls' value if
>  the lookup met the end of chain. If final 'nulls' value
>  is not the slot number, then we must restart the lookup at
> -the begining. If the object was moved to same chain,
> +the beginning. If the object was moved to same chain,


"by way":)
 +the beginning. If the object was moved to the same chain,

Jarek P.

>  then the reader doesnt care : It might eventually
>  scan the list again without harm.
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


