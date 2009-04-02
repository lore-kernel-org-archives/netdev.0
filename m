From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 16:52:53 +0800
Message-ID: <20090402085253.GA29932@gondor.apana.org.au>
References: <49D46089.5040204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D46089.5040204@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avi Kivity <avi@redhat.com> wrote:
>
> virtio is already non-kvm-specific (lguest uses it) and non-pci-specific 
> (s390 uses it).

I think Greg's work shows that putting the backend in the kernel
can dramatically reduce the cost of a single guest->host transaction.
I'm sure the same thing would work for virtio too.

> If you have a good exit mitigation scheme you can cut exits by a factor 
> of 100; so the userspace exit costs are cut by the same factor.  If you 
> have good copyless networking APIs you can cut the cost of copies to 
> zero (well, to the cost of get_user_pages_fast(), but a kernel solution 
> needs that too).

Given the choice of having to mitigate or not having the problem
in the first place, guess what I would prefer :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
