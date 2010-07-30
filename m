From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo
	header
Date: Fri, 30 Jul 2010 18:24:09 +0800
Message-ID: <20100730102409.GA8590@gondor.apana.org.au>
References: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com> <20100730090922.GA7807@gondor.apana.org.au> <AANLkTi=YHvra6DuL7vX=DfQmR6bsw7rNMJ9mRhUzHvj2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43846 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab0G3KYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 06:24:17 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=YHvra6DuL7vX=DfQmR6bsw7rNMJ9mRhUzHvj2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 30, 2010 at 06:10:19PM +0800, Changli Gao wrote:
>
> Is it really necessary, and I have noticed that netfilter doesn't call
> inet_proto_csum_replace4 in this way.

The checksum update is for the inner IP header.  netfilter does
of course update the checksum, it just doesn't do it here which is
for the outer IP header.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
