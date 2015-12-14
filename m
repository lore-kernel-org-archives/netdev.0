From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] netlink: fix boolean evaluation on bound
Date: Mon, 14 Dec 2015 22:07:04 +0100
Message-ID: <566F2F78.8020705@stressinduktion.org>
References: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
 <20151214170642.GA4180@gondor.apana.org.au>
 <566EFBF0.5020604@stressinduktion.org>
 <1450115411.8474.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47616 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932296AbbLNVHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:07:07 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 53CCA20B0B
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 16:07:07 -0500 (EST)
In-Reply-To: <1450115411.8474.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.12.2015 18:50, Eric Dumazet wrote:
> On Mon, 2015-12-14 at 18:27 +0100, Hannes Frederic Sowa wrote:
> 
>> Otherwise I would recommend adding a "!!" to express that we actually
>> want bound set based on the portid value?
> 
> Note that compiler already does the !! thing, when you store an integer
> into a bool var.

Exactly, the gcc compiler does that automatically when writing to a
_Bool type.

> So it definitely is a matter of taste and code readability.

Yes, as I wrote, this patch doesn't alter the any runtime behavior, it
confused me and thus I wanted to make the assignment more explicit.

It looked like a trap to me, thus I wanted to change it.

Bye,
Hannes
