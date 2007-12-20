From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 11:26:18 +0800
Message-ID: <E1J5C38-0004kh-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0712200000050.27945@kivilampi-30.cs.helsinki.fi>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1126 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753528AbXLTD0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 22:26:42 -0500
In-Reply-To: <Pine.LNX.4.64.0712200000050.27945@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>
>> is the limitting factor? For latter IMHO this would be necessary:
>> 
>>                       if (skb->len > limit)
>>                               limit -= limit % mss_now;

Good catch! But how about putting this logic into tcp_window_allows
since then you can avoid the divide for the case when we're not
bound by the receiver window.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
