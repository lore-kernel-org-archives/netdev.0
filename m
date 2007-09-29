From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH 2/3] UDP memory usage accounting: accounting unit and variable
Date: Sat, 29 Sep 2007 11:22:55 +0800
Message-ID: <E1IbSut-00009d-00@gondolin.me.apana.org.au>
References: <46FD009B.1010904@hitachi.com>
Cc: andi@firstfloor.org, netdev@vger.kernel.org, haoki@redhat.com,
	yoshfuji@linux-ipv6.org, yumiko.sugita.yf@hitachi.com
To: satoshi.oshima.fk@hitachi.com (Satoshi OSHIMA)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2241 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753958AbXI2DXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 23:23:03 -0400
In-Reply-To: <46FD009B.1010904@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> wrote:
>
> I understand what you pointed out. But I think the accounting
> method I'm proposing is very similar to TCP accounting and per
> socket accounting.
> How do you think of it?

I think allowing Joe user to stop root from using TCP or UDP
isn't much better than having him hog kernel memory.

So let's fix this properly and add per-user limits rather than
system-wide ones.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
