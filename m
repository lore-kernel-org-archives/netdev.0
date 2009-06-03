From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] tun: virtio net is not compatible with LRO
Date: Wed, 3 Jun 2009 16:52:55 +0930
Message-ID: <200906031652.56084.rusty@rustcorp.com.au>
References: <20090603052335.GA20823@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43577 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756073AbZFCHeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2009 03:34:19 -0400
In-Reply-To: <20090603052335.GA20823@sequoia.sous-sol.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Jun 2009 02:53:35 pm Chris Wright wrote:
> The current failure mode for an LRO device bridged to a virtio device
> (common for KVM) is BUG().  Rather than crashing the host, we can at
> least limp along and give a warning.  lro_flush() will set gso_size,
> but no corresponding gso_type, unlike gro which will eventually call
> ->gro_complete and set up proper gso_type.

So, skb_is_gso() is true, but it's not actually a gso frame?

I know nothing about LRO, but that seems wrong.  If you bridge any other GSO 
device with an LRO device, does that do random things as well?

Thanks,
Rusty.
