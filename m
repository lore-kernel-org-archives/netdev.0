From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 17:50:11 +0800
Message-ID: <20150804095011.GA28055@gondor.apana.org.au>
References: <063D6719AE5E284EB5DD2968C1650D6D1CB727D0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bblanco@plumgrid.com, netdev@vger.kernel.org, davem@davemloft.net,
	khlebnikov@yandex-team.ru
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52240 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932382AbbHDJuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 05:50:23 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB727D0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@aculab.com> wrote:
>
> In that case, what happens to the receive queue when skb_clone()
> takes a copy of the skb - freeing the original one?

The new skb is inserted into the recv queue and replacing the
existing skb.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
