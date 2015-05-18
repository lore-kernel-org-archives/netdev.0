From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Mon, 18 May 2015 16:31:21 +0800
Message-ID: <20150518083121.GA18195@gondor.apana.org.au>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
 <20150516123457.GB683@gondor.apana.org.au>
 <20150516.171328.1953881469617376252.davem@davemloft.net>
 <20150518070427.GC8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org, tgraf@suug.ch
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36422 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbERIbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 04:31:35 -0400
Content-Disposition: inline
In-Reply-To: <20150518070427.GC8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 09:04:27AM +0200, Steffen Klassert wrote:
>
> The policy and state mark must match the tunnels i_key/o_key
> on lookup. It is not required to set skb->mark, but we have
> to make sure to use the tunnels gre keys as the mark when we
> do a policy or state lookup.

So is it possible to restore the original mark after the lookups?
At least that way it is still possible to use the mark before and
after the encapsulation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
