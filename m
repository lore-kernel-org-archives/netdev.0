From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/7] IPsec: More work on async crypto on output
Date: Tue, 9 Oct 2007 22:35:17 +0800
Message-ID: <20071009143517.GA20486@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4973 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752771AbXJIOfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:35:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

Here's another round of patches which ends with the moving down
of the state lock into x->type->output.  I need to stop getting
distracted by fixing bugs and concentrate on creating them :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
