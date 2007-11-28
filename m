From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Wed, 28 Nov 2007 10:16:40 +0900
Message-ID: <200711281016.40946.nakam@linux-ipv6.org>
References: <20071009143517.GA20486@gondor.apana.org.au> <20071126031845.GA23417@gondor.apana.org.au> <20071126110720.GA26479@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:39738 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757500AbXK1BRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 20:17:07 -0500
In-Reply-To: <20071126110720.GA26479@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

Monday 26 November 2007 20:07, Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 11:18:45AM +0800, Herbert Xu wrote:
> >
> > I'm just going to revert this patch for 2.6.24 since we've lived
> > with this race for so long anyway.
> 
> Actually, instead of reverting it completely I'm just going to
> remove the newly added locks which should be just as effective.
> 
> This would reduce the churn in the code as we'd be putting most
> of it back soon anyway.

With the patch you sent, the xfrm_state_walk() issue I reported
is solved at current net-2.6.25.

-- 
Masahide NAKAMURA
