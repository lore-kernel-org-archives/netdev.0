From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] vlan: GRO rx statistics
Date: Sat, 14 Nov 2009 09:27:41 +0800
Message-ID: <20091114012741.GA18764@gondor.apana.org.au>
References: <4AF99A50.5080301@gmail.com> <4AFD8C31.10703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59729 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753048AbZKNB1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 20:27:42 -0500
Content-Disposition: inline
In-Reply-To: <4AFD8C31.10703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 05:41:21PM +0100, Eric Dumazet wrote:
>
> Replying to myself, I found root of the problem and posted a fix.

Just curious, do you have a link to that fix?

> Still the race while updating dev->stats.tx_{bytes|packets} should be addressed eventually...

Well making it per-napi_struct should do the trick.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
