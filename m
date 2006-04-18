From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP]: Fix truesize underflow
Date: Wed, 19 Apr 2006 09:27:13 +1000
Message-ID: <20060418232713.GA11938@gondor.apana.org.au>
References: <20060418123204.GA3962@gondor.apana.org.au> <20060418.132256.110004342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bb@kernelpanic.ru, kernel@linuxace.com, nipsy@bitgnome.net,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com, ak@suse.de,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49166 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750798AbWDRX3h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 19:29:37 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060418.132256.110004342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2006 at 01:22:56PM -0700, David S. Miller wrote:
> 
> I think it is deserving of some run time assertions, else these bugs
> will elude us continually.  Luckily there are only a few places that
> would need the run time assertion checks on skb->truesize, and I'll
> try to spend a few cycles on implementing this soon.

Yes indeed.  One place that comes to mind would be tcp_trim_head just
before we munge truesize.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
