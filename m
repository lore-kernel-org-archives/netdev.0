From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Thu, 14 May 2015 11:28:33 +0800
Message-ID: <20150514032833.GF3853@gondor.apana.org.au>
References: <20150514020316.1635.50870.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	tgraf@suug.ch, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43672 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbbEND2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:28:39 -0400
Content-Disposition: inline
In-Reply-To: <20150514020316.1635.50870.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 07:04:28PM -0700, Alexander Duyck wrote:
> This change makes it so that we clear the skb->mark field when we pass
> through the receive path of the IPv4 or IPv6 virtual tunnel interface.  The
> reason for clearing these fields is to resolve an apparent regression for
> the behavior before skb_scrub_packet was modified.  Without this patch I
> have to set disable_policy for the vti tunnel endpoint in order to be able
> to receive traffic.
> 
> Fixes: 213dd74aee76 ("skbuff: Do not scrub skb mark within the same name space")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

This patch makes no sense.  Please explain your problem more
clearly and tell us why the mark changes the way your packet
is dealt with and why this isn't a policy decision that should
be made in user-space.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
