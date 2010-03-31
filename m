From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 10:15:11 -0400
Message-ID: <1270044911.26743.62.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
	 <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi>
	 <1270042883.26743.32.camel@bigi>
	 <20100331135629.GD14082@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:64991 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756302Ab0CaOPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:15:18 -0400
Received: by ewy20 with SMTP id 20so44591ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 07:15:17 -0700 (PDT)
In-Reply-To: <20100331135629.GD14082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 21:56 +0800, Herbert Xu wrote:

> 
> No you've changed it.  PF_KEY will no longer notify if the policy
> table is empty.
> 
> This is inconsistent with the behaviour of SADB flushes, and the
> spirit of RFC2367.

I did not mean to change it for pfkey. I do believe there are apps that
need it.
I will run some tests and if it breaks - I will send a patch.

cheers,
jamal

