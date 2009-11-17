From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to
	speedup device dismantle
Date: Tue, 17 Nov 2009 20:31:33 +0800
Message-ID: <20091117123133.GA14831@gondor.apana.org.au>
References: <4B019381.2010509@gmail.com> <4B01C938.8000705@gmail.com> <20091116143917.14e4fa4f@s6510> <20091117.042604.99618154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37345 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752454AbZKQMbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:31:34 -0500
Content-Disposition: inline
In-Reply-To: <20091117.042604.99618154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2009 at 04:26:04AM -0800, David Miller wrote:
>
> Really, the link watch stuff is just due for a redesign.  I don't
> think a simple hack is going to cut it this time, sorry Eric :-)

I have no objections against any redesigns, but since the only
caller of linkwatch_forget_dev runs in process context with the
RTNL, it could also legally emit those events.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
