From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network	device	driver.
Date: Tue, 09 May 2006 23:01:05 +1000
Message-ID: <E1FdRpp-0008HG-00@gondolin.me.apana.org.au>
References: <20060509124359.GA5407@cl.cam.ac.uk>
Cc: herbert@gondor.apana.org.au, xen-devel@lists.xensource.com,
	ian.pratt@xensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5138 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932301AbWEINBR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 09:01:17 -0400
To: Christian.Limpach@cl.cam.ac.uk (Christian Limpach)
In-Reply-To: <20060509124359.GA5407@cl.cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> 
> There's at least two reasons why having it in the driver is preferable:
> - synchronizing sending the fake ARP request with when the device is
>  operational -- you really want to make this well synchronized to keep
>  unreachability as short as possible, especially when doing live
>  migration
> - anybody but the guest might not know (all) the MAC addresses for which
>  to send a fake ARP request

Sure.  However, what's there to stop you from doing this in user-space
inside the guest?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
