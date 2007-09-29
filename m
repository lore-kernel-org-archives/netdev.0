From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Sat, 29 Sep 2007 11:21:05 +0800
Message-ID: <E1IbSt7-000091-00@gondolin.me.apana.org.au>
References: <46FD0117.9030407@hitachi.com>
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org, haoki@redhat.com,
	yoshfuji@linux-ipv6.org, yumiko.sugita.yf@hitachi.com
To: satoshi.oshima.fk@hitachi.com (Satoshi OSHIMA)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2227 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752518AbXI2DVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 23:21:47 -0400
In-Reply-To: <46FD0117.9030407@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> wrote:
>
> In such case, from 300 to 500MB memory consumption will
> be fatal. Users can easily open 1000 sockets per process
> under default ulimit. If such sockets hold messages but
> user processes don't receive it. Almost all slab will
> be occupied by sk_buff.

Well the solution to that is to have a per-user limit rather
than a system-wide limit.  Otherwise any user can stop system
daemons from using UDP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
