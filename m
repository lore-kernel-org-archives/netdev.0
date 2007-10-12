From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tc_verd vs. skb_clone
Date: Fri, 12 Oct 2007 22:00:27 +0800
Message-ID: <20071012140026.GA27761@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1892 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752471AbXJLOAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 10:00:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal:

I was wondering why we're not copying tc_verd as is in skb_clone.
In particular, this makes pskb_copy behave differently compared
to skb_clone and I can't find a justificatino for it.

Any ideas?

Also we don't seem to copy iif in copy_skb_header.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
