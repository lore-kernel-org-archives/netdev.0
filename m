From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: neigh_lookup lockdep bug.
Date: Wed, 02 Aug 2006 04:20:46 +0200
Message-ID: <1154485266.3030.17.camel@laptopd505.fenrus.org>
References: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-nvb.com ([69.27.17.200]:46491 "EHLO e-nvb.com")
	by vger.kernel.org with ESMTP id S1751055AbWHBCV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 22:21:27 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G7u9v-0001mL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-01 at 23:19 +1000, Herbert Xu wrote:
> 
> I've only briefly looked at the lockdep_set_class code so I might be
> way off here.

your reading of the code is right, and in fact this is what the code in
-mm does, and is waiting for the networking guys or Andrew to send it to
Linus (hint hint)


Greetings,
   Arjan van de Ven

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

