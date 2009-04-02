From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 11:11:41 +0800
Message-ID: <20090402031141.GA27878@gondor.apana.org.au>
References: <20090401204039.GR18394@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, andi@firstfloor.org, ghaskins@novell.com,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38049 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753470AbZDBDMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:12:12 -0400
Content-Disposition: inline
In-Reply-To: <20090401204039.GR18394@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Wright <chrisw@sous-sol.org> wrote:
>
>> That said, I don't think we're bound today by the fact that we're in  
>> userspace.  Rather we're bound by the interfaces we have between the  
>> host kernel and userspace to generate IO.  I'd rather fix those  
>> interfaces than put more stuff in the kernel.
> 
> And more stuff in the kernel can come at the potential cost of weakening
> protection/isolation.

Protection/isolation always comes at a cost.  Not everyone wants
to pay that, just like health insurance :) We should enable the
users to choose which model they want, based on their needs.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
