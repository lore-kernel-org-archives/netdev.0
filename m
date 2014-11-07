From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/4] Replace skb_copy_datagram_const_iovec with iterator
 version
Date: Fri, 7 Nov 2014 21:21:35 +0800
Message-ID: <20141107132135.GA20022@gondor.apana.org.au>
References: <20141106082338.GA29800@gondor.apana.org.au>
 <20141106.122500.4643339498907490.davem@davemloft.net>
 <20141107015944.GB9101@gondor.apana.org.au>
 <20141106.221313.1375322315446025123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56565 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbaKGNVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 08:21:48 -0500
Content-Disposition: inline
In-Reply-To: <20141106.221313.1375322315446025123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This patch series adds the helper skb_copy_datagram_iter, which
is meant to replace both skb_copy_datagram_iovec and its evil
twin skb_copy_datagram_const_iovec.

It then converts tun and macvtap over to the new helper and finally
removes skb_copy_datagram_const_iovec which is only used by tun
and macvtap.

The copy_to_iter return value issue pointed out by Al has now been
fixed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
