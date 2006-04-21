From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Fri, 21 Apr 2006 12:23:16 +1000
Message-ID: <E1FWlIi-0007fR-00@gondolin.me.apana.org.au>
References: <20060420.173853.60273448.davem@davemloft.net>
Cc: andy.grover@gmail.com, olof@lixom.net, andrew.grover@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from CyborgDefenseSystems.Corporatebeast.com ([64.62.148.172]:14867
	"EHLO arnor.apana.org.au") by vger.kernel.org with ESMTP
	id S1750785AbWDUCXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 22:23:31 -0400
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20060420.173853.60273448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> For I/O AT you'd really want to get the DMA engine going as soon
> as you had those packets, but I do not see a clean and reliable way
> to determine the target pages before the app gets back to recvmsg().

The vmsplice() system call proposed by Linus might be a good fit.

http://www.ussg.iu.edu/hypermail/linux/kernel/0604.2/0854.html
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
