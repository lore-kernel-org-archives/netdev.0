From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 13:47:57 -0400
Message-ID: <1270057677.26743.116.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <1270042092.26743.26.camel@bigi>
	 <20100331135331.GB14082@gondor.apana.org.au>  <4BB37B48.5020308@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:39785 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757910Ab0CaRsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 13:48:04 -0400
Received: by ewy20 with SMTP id 20so112819ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 10:48:02 -0700 (PDT)
In-Reply-To: <4BB37B48.5020308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 18:41 +0200, Patrick McHardy wrote:

> I agree with Herbert, the flush notification indicates that
> the table is now empty, independant of its previous state.

What purpose does it serve?

As an example, if i delete an entry, the fact i deleted an entry is 
of interest to some manager in user space for the purpose of syncing.
If i brought a link down, same thing. If i brought a link down
that was already down - why would that be of interest to generate
as an event? etc.

cheers,
jamal

