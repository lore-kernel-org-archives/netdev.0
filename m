From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
	with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 16:37:02 +1100
Message-ID: <20090115053702.GA30403@gondor.apana.org.au>
References: <496D61FE.7080500@cn.fujitsu.com> <20090114044856.GA14726@gondor.apana.org.au> <20090114.210242.163189105.davem@davemloft.net> <496ECACB.5090300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37395 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750874AbZAOFhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:37:09 -0500
Content-Disposition: inline
In-Reply-To: <496ECACB.5090300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 01:34:03PM +0800, Yang Hongyang wrote:
> 
> Dave,there are some of the code elsewhere return EFAULT when
> optval=NULL,I will post a patch to fix them:)

I disagree.  The concept of a user-space NULL pointer is different
to that of a kernel-space NULL pointer, so the kernel should not
be treating a user-space NULL pointer differently than any other
pointer.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
