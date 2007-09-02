From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink code
Date: Sun, 02 Sep 2007 12:04:45 +0800
Message-ID: <E1IRghZ-0004EL-00@gondolin.me.apana.org.au>
References: <46D9957F.4020101@trash.net>
Cc: link@miggy.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: kaber@trash.net (Patrick McHardy)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1899 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750748AbXIBEFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 00:05:11 -0400
In-Reply-To: <46D9957F.4020101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> Thanks. I'm not sure either, it would require two concurrent requests
> to be processed, but AFAICS oidentd only uses a single netlink socket.
> Perhaps multiple running instances or something else using the inet_diag
> interface?

Since identd serves requests from the outside world it is
quite possible for two identd instances to run simultaneously
serving two requests.

I'm not familiar with oidentd but this is certainly pidentd
works.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
