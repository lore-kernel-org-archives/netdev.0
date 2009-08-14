From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ifb and gso problem
Date: Fri, 14 Aug 2009 20:28:11 +1000
Message-ID: <20090814102811.GA5505@gondor.apana.org.au>
References: <200908141250.11876.avl@strace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: avl@strace.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58361 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752319AbZHNK2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 06:28:14 -0400
Content-Disposition: inline
In-Reply-To: <200908141250.11876.avl@strace.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Labutcky <avl@strace.net> wrote:
> 
> When downloading from 192.168.1.1, speed not exceeds 256-300kbit/s on 100mbit link.
> After disabling gso - speed becomes 100mbit/s.
> 
> Patch below fixed this problem.

It's already fixed:

commit 82c49a352e0fd7af7e79a922b863f33f619f3209
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri May 22 22:11:37 2009 +0000

    skbuff: Move new code into __copy_skb_header

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
