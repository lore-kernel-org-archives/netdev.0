From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 13:29:04 +0800
Message-ID: <20150416052904.GA12648@gondor.apana.org.au>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
 <20150416045622.GA12454@gondor.apana.org.au>
 <20150416052357.GA3285@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36480 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbbDPF3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 01:29:11 -0400
Content-Disposition: inline
In-Reply-To: <20150416052357.GA3285@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
>
> Netfilter may change the contents of the packet, even change its size.
> It is *really* hard to do this while keeping the original fragments
> intact.

Perhaps we should provide better helpers to facilitate this?

So instead of directly manipulating the content of the skb you
would so so through helpers and the helpers can then try to do
sensible things with the fragments.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
