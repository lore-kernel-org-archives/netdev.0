From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the netmask/prefix-length
Date: Thu, 29 Nov 2007 21:34:59 +1100
Message-ID: <20071129103459.GD22537@gondor.apana.org.au>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	Joy Latten <latten@us.ibm.com>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1862 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751248AbXK2KfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:35:04 -0500
Content-Disposition: inline
In-Reply-To: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 07:55:12PM +0000, Paul Moore wrote:
> Currently the netmask/prefix-length of an IPsec SPD entry is not included in
> any of the SPD related audit messages.  This can cause a problem when the
> audit log is examined as the netmask/prefix-length is vital in determining
> what network traffic is affected by a particular SPD entry.  This patch fixes
> this problem by adding two additional fields, "src_prefixlen" and
> "dst_prefixlen", to the SPD audit messages to indicate the source and
> destination netmasks.  These new fields are only included in the audit message
> when the netmask/prefix-length is less than the address length, i.e. the SPD
> entry applies to a network address and not a host address.

Any reason why we don't just always include them?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
