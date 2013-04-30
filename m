From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v2 3/3] bridge: send query as soon as leave is
 received
Date: Tue, 30 Apr 2013 12:07:36 +0800
Message-ID: <20130430040736.GA20799@gondor.apana.org.au>
References: <1367293270-26256-1-git-send-email-amwang@redhat.com>
 <1367293270-26256-3-git-send-email-amwang@redhat.com>
 <20130430034538.GA20631@gondor.apana.org.au>
 <1367294717.3216.11.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41777 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750854Ab3D3EHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 00:07:40 -0400
Content-Disposition: inline
In-Reply-To: <1367294717.3216.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 12:05:17PM +0800, Cong Wang wrote:
>
> When port is NULL, the query should only be sent to bridge itself, so I
> think this is what we expect, right? Since we receive leave from bridge
> itself.

No I'm not talking about which port it's being sent to (which
obviously should only be the port where the leave arrived on),
but what is in the query message.

A general query queries every single group out there, for a leave
we need to specifically query for the group that is being left.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
