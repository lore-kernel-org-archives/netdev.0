From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the
 list
Date: Fri, 9 Jan 2015 13:34:21 +1100
Message-ID: <20150109023421.GA16089@gondor.apana.org.au>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
 <20150108111554.GA8720@gondor.apana.org.au>
 <CA+U0gVgZr-Mhzest1O_vtCWMwuaQmP30DYb8CLXDG8iTobObYQ@mail.gmail.com>
 <20150109022752.GA15785@gondor.apana.org.au>
 <CA+U0gVgS7z601DZvL82EJfYGYb5XQExw9CbnPRpUeN32TWLF7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43779 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbAICeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 21:34:24 -0500
Content-Disposition: inline
In-Reply-To: <CA+U0gVgS7z601DZvL82EJfYGYb5XQExw9CbnPRpUeN32TWLF7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 10:32:13AM +0800, Dennis Chen wrote:
>
> Thanks, would you pls give me an example of those drivers? I'll study
> it further...

There are no known drivers doing this currently since that would
be a bug and they would be fixed quickly.  But if you look back
in history virtio_net was doing this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
