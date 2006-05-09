From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual network device	driver.
Date: Tue, 09 May 2006 21:55:33 +1000
Message-ID: <E1FdQoP-0007iN-00@gondolin.me.apana.org.au>
References: <20060509085201.446830000@sous-sol.org>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	Christian.Limpach@cl.cam.ac.uk, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, ian.pratt@xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59408 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932397AbWEILzy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 07:55:54 -0400
To: chrisw@sous-sol.org (Chris Wright)
In-Reply-To: <20060509085201.446830000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris:

Chris Wright <chrisw@sous-sol.org> wrote:
>
> +/** Send a packet on a net device to encourage switches to learn the
> + * MAC. We send a fake ARP request.
> + *
> + * @param dev device
> + * @return 0 on success, error code otherwise
> + */
> +static int send_fake_arp(struct net_device *dev)

I think we talked about this before.  I don't see why Xen is so special
that it needs its own gratuitous arp routine embedded in the driver.
If this is needed at all (presumably for migration) then it should be
performed by the management scripts which can send grat ARP packets just
as easily.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
