From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: IPv4: ip_options_compile() how can we avoid blowing up on a NULL skb???
Date: Thu, 16 Nov 2006 22:46:18 -0500
Message-ID: <200611162246.21018.dtor@insightbb.com>
References: <E1GkrjY-0004Dt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:15701 "EHLO
	asav01.insightbb.com") by vger.kernel.org with ESMTP
	id S1162354AbWKQErs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 23:47:48 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GkrjY-0004Dt-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 16 November 2006 19:37, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> >
> > I'm very happy to accept a patch which assert's this using BUG()
> > checks :-)
> 
> A BUG() won't be necessary because the NULL pointer dereferences will
> OOPS anyway.
>

BUG()s there would be a mechanism to document invariants so next time
someone is looking at the code there are no questions.

-- 
Dmitry
