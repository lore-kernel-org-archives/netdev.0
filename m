From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH for-2.6.35] tun: avoid BUG, dump packet on GSO errors
Date: Thu, 22 Jul 2010 21:05:12 +0800
Message-ID: <20100722130512.GA29088@gondor.apana.org.au>
References: <20100721143245.GA8423@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48124 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759295Ab0GVNFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 09:05:15 -0400
Content-Disposition: inline
In-Reply-To: <20100721143245.GA8423@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin <mst@redhat.com> wrote:
> There are still some LRO cards that cause GSO errors in tun,
> and BUG on this is an unfriendly way to tell the admin
> to disable LRO.
> 
> Further, experience shows we might have more GSO bugs lurking.
> See https://bugzilla.kernel.org/show_bug.cgi?id=16413
> as a recent example.
> dumping a packet will make it easier to figure it out.
> 
> Replace BUG with warning+dump+drop the packet to make
> GSO errors in tun less critical and easier to debug.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Tested-by: Alex Unigovsky <unik@compot.ru>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
