From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Sun, 29 Mar 2009 15:48:49 -0700
Message-ID: <20090329224849.GH11362@linux.vnet.ibm.com>
References: <20090329215103.27553.29216.stgit@localhost.localdomain> <20090329215257.27553.43721.stgit@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51901 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbZC2WtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2009 18:49:08 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2TMk7Pv012900
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:46:07 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TMmoPf172524
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:48:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TMmne5026955
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 18:48:50 -0400
Content-Disposition: inline
In-Reply-To: <20090329215257.27553.43721.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 29, 2009 at 11:52:57PM +0200, Jesper Dangaard Brouer wrote:
> Trival spelling fixes in RCU/rculist_nulls.txt.

Good eyes!

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

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
>  then the reader doesnt care : It might eventually
>  scan the list again without harm.
> 
> 
