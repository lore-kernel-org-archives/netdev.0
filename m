From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/4] Replace skb_copy_datagram_const_iovec with iterator
 version
Date: Thu, 6 Nov 2014 16:27:04 +0800
Message-ID: <20141106082704.GB29800@gondor.apana.org.au>
References: <20141104033818.GA11149@gondor.apana.org.au>
 <E1XlZWY-0003HZ-Ef@gondolin.me.apana.org.au>
 <20141105.152410.1775725940252546246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141105.152410.1775725940252546246.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This patch series adds the helper skb_copy_datagram_iter, which
is meant to replace both skb_copy_datagram_iovec and its evil
twin skb_copy_datagram_const_iovec.

It then converts tun and macvtap over to the new helper and finally
removes skb_copy_datagram_const_iovec which is only used by tun
and macvtap.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
