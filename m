From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: question about UFO behavior for bridge device
Date: Sat, 14 May 2011 00:36:27 +1000
Message-ID: <20110513143627.GA29054@gondor.apana.org.au>
References: <4DCCF803.5020805@cn.fujitsu.com> <1305292012.4065.441.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57155 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab1EMOgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 10:36:32 -0400
Content-Disposition: inline
In-Reply-To: <1305292012.4065.441.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2011 at 02:06:52PM +0100, Ben Hutchings wrote:
>
> > But, actually, i saw original big skb in eth0's tcpdump file, but not segmented skbs.
> > The behavior is right or what we want?
> > Is there anything missed about my analysis?
> 
> I assume that packet capturing is handled earlier in the transmit path.

Yes it is.  It's the same with TSO.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
