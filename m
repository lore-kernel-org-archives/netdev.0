From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next PATCH RFC 0/3] Preserve skb->mark through VTI tunnels
Date: Wed, 27 May 2015 15:55:28 +0800
Message-ID: <20150527075528.GA26671@gondor.apana.org.au>
References: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52695 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbbE0Hzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 03:55:38 -0400
Content-Disposition: inline
In-Reply-To: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 03:41:10PM -0700, Alexander Duyck wrote:
> These patches are meant to try and address the fact the VTI tunnels are
> currently overwriting the skb->mark value.  I am generally happy with the
> first two patches, however the third patch still modifies the skb->mark,
> though it undoes after the fact.
> 
> The main problem I am trying to address is the fact that currently if I use
> an v6 over v6 VTI tunnel I cannot receive any traffic on the interface as
> the skb->mark is bleeding through and causing the traffic to be dropped.

Looks good to me.  Thanks for following up on this!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
