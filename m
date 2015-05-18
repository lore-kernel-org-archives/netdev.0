From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Mon, 18 May 2015 18:33:37 +0800
Message-ID: <20150518103337.GA19613@gondor.apana.org.au>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
 <20150516123457.GB683@gondor.apana.org.au>
 <20150516.171328.1953881469617376252.davem@davemloft.net>
 <20150518070427.GC8928@secunet.com>
 <20150518083121.GA18195@gondor.apana.org.au>
 <20150518083843.GF8928@secunet.com>
 <20150518085908.GA18381@gondor.apana.org.au>
 <20150518103045.GG8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org, tgraf@suug.ch
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52134 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbbERKdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 06:33:49 -0400
Content-Disposition: inline
In-Reply-To: <20150518103045.GG8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 12:30:47PM +0200, Steffen Klassert wrote:
>
> Or, maybe we can create new vti tunnel keys and some key
> field in the xfrm_policy and xfrm_state. If the vti keys
> are present at the tunnel, use the new flow lookup field
> and match with the key field of the policy and state.
> Otherwise, fallback to use gre keys and mark.

Yes that could work.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
