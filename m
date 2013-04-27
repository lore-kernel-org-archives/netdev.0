From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] bridge: do not expire mdb entry as long as
 bridge still uses it
Date: Sat, 27 Apr 2013 23:40:45 +0800
Message-ID: <1367077245.22748.1.camel@cr0>
References: <1366878083-22797-1-git-send-email-amwang@redhat.com>
	 <20130425083704.GA27420@gondor.apana.org.au> <1366884421.11488.4.camel@cr0>
	 <20130426125023.GA4812@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755520Ab3D0PlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 11:41:04 -0400
In-Reply-To: <20130426125023.GA4812@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-26 at 20:50 +0800, Herbert Xu wrote:
> So we need to do two things:
> 
> 1) Fix the group timeout mechanism to only arm the timer when a
> corresponding query is received.
> 2) Resume sending queries when leave is received if the user makes
> a querier.

Agreed.

> 
> Let me know if you'd like to work on this, otherwise I can take
> a look at it next week.
> 

Yeah, I will work on it.

Thanks for the suggestion!
