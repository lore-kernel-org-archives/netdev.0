From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Sat, 1 Dec 2007 12:54:38 +1100
Message-ID: <20071201015438.GC26895@gondor.apana.org.au>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3224 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755756AbXLABy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 20:54:58 -0500
Content-Disposition: inline
In-Reply-To: <20071130111949.GB28277@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 11:19:49AM +0000, Gerrit Renker wrote:
>
> |  csum_copy_err:
> | -	UDP6_INC_STATS_USER(UDP_MIB_INERRORS, is_udplite);
> | +	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
> |  	skb_kill_datagram(sk, skb, flags);
> |  
> |  	if (flags & MSG_DONTWAIT)
> | 
> Is it not the other way round ?? :- 

I agree.  Wang Chen, please change this and other appropriate
BH calls to USER.  Basically recvmsg should always be USER while
rcv is BH.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
