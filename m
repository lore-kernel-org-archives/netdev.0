From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Mon, 31 Dec 2007 20:11:45 +1100
Message-ID: <20071231091145.GA28133@gondor.apana.org.au>
References: <47775D8C.5010104@redhat.com> <47775E7A.60708@redhat.com> <20071231.001925.151533664.davem@davemloft.net> <4778AE48.1040701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, haoki@redhat.com,
	netdev@vger.kernel.org, tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1815 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753544AbXLaJMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 04:12:01 -0500
Content-Disposition: inline
In-Reply-To: <4778AE48.1040701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 09:54:32AM +0100, Eric Dumazet wrote:
>
> Maybe I read the patch incorrectly, or we could add some new sysctl so that
> we not try to uncharge memory if a socket 'forward_alloc' is beyond a given 
> limit (say 2 pages), so that number of atomic_inc/dec on 
> udp_memory_allocated (or tcp_memory_allocated) is reduced.

I don't have time to go through these patches right now but
that was the whole point of using forward_alloc, i.e., avoid
touching the global for every packet.

So if it's still doing that then we're doing something wrong.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
