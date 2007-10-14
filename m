From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/10] Remove sk_buff ** from netfilter API
Date: Sun, 14 Oct 2007 12:26:04 +0800
Message-ID: <20071014042604.GA11431@gondor.apana.org.au>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au> <46FFC2F4.8090602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1365 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751157AbXJNE0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:26:39 -0400
Content-Disposition: inline
In-Reply-To: <46FFC2F4.8090602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 30, 2007 at 05:38:28PM +0200, Patrick McHardy wrote:
>
> >From a quick look it seems at least IPv4 and IPv6 don't need to
> change the skb anywhere else. It seems to be necessary for
> bridging though to unshare the skb. OTOH br_netfilter.c already
> unshares the skb for IPv4 and IPv6, so we could simply do this
> unconditionally before calling the hooks.

Thanks.  I got bored and finally did the plunge :)

I've booted it here and it seems to work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
