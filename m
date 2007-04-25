From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] [IPV6]: Consolidate common SNMP code
Date: Wed, 25 Apr 2007 15:54:05 +1000
Message-ID: <20070425055405.GB5505@gondor.apana.org.au>
References: <20070425040637.GA4838@gondor.apana.org.au> <20070425.132103.129791594.yoshfuji@linux-ipv6.org> <20070424.215429.42460618.davem@davemloft.net> <20070424.221239.00772916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2258 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754671AbXDYFyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 01:54:09 -0400
Content-Disposition: inline
In-Reply-To: <20070424.221239.00772916.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 10:12:39PM -0700, David Miller wrote:
> 
> This breaks the build with IPV6 modular:
> 
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `snmp6_seq_show':
> proc.c:(.text+0x68244): undefined reference to `ipv6_statistics'

Sorry, got carried away with testing with /proc turned off :)
Thanks for fixing it up!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
