From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Mon, 2 Oct 2006 12:24:47 +0200
Message-ID: <20061002102447.GA2936@ff.dom.local>
References: <200609302223.47627.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: axboe@suse.de, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:6036 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1750733AbWJBKUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 06:20:18 -0400
To: Ismail Donmez <ismail@pardus.org.tr>
Content-Disposition: inline
In-Reply-To: <200609302223.47627.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30-09-2006 21:23, Ismail Donmez wrote:
> Hi,
> 
> With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
> changed behaviour so it returns false when the node is empty as expected. 
...
> -	if (!RB_EMPTY_NODE(rb)) {
> +	if (RB_EMPTY_NODE(rb)) {

Maybe you have some kind of agreement with Jens Axboe but I
can't understand current way of kernel cooperation:
he changes some global behavior to the opposite and fixes
his code in three places but can't fix it in the fourth place
where it's used? Isn't it both trivial and automatic kind
of patch?

Second question is this title alarming enough?: 
"[PATCH] rbtree: fixed reversed RB_EMPTY_NODE and rb_next/prev"

Maybe:
[PATCH] rbtree: reversed RB_EMPTY_NODE and fixed rb_next/prev

but shouldn't there be some special [XYZ!] keyword used for
such severe situations? 

Jarek P.  
