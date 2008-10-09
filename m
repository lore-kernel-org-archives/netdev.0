From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] gre: Ethernet over GRE
Date: Thu, 9 Oct 2008 15:04:24 +0800
Message-ID: <20081009070424.GA16684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34527 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754671AbYJIHE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:04:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This series of patches add Ethernet over GRE support.  The user
space interface is done with the rtnl_link mechanism.  I'll post
the patches for iproute too.

There has been a small demand of such a tunneling mechanism that
allows direct Ethernet connections over IP.  In the past many
efforts have been made in this direction.  However, inadequacies
with our user interface have foiled many of them.

Recently Patrick McHardy created the rtnl_link mechanism which
finally allows tunnel configuration to be brought into the 21st
century.  Having tried it I must say that it has been an absolute
pleasure to use :)

This should be completely backwards compatible in that if you
don't create Ethernet over GRE tunnels then your GRE experience
should not differ one single bit from before.  However, you can
manage your existing GRE interfaces using the new interface should
you choose to do so.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
