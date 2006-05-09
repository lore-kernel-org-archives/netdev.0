From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network device	driver.
Date: Wed, 10 May 2006 08:41:29 +1000
Message-ID: <E1FdatV-0000lj-00@gondolin.me.apana.org.au>
References: <20060509085201.446830000@sous-sol.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	Christian.Limpach@cl.cam.ac.uk, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, ian.pratt@xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5392 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751327AbWEIWmF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:42:05 -0400
To: chrisw@sous-sol.org (Chris Wright)
In-Reply-To: <20060509085201.446830000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Wright <chrisw@sous-sol.org> wrote:
>
> +       netdev->features        = NETIF_F_IP_CSUM;

Any reason why IP_CSUM was chosen instead of HW_CSUM? Doing the latter
would seem to be in fact easier for a virtual driver, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
