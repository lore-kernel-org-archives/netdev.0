From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 11:27:30 +0800
Message-ID: <20111109032729.GA11312@gondor.apana.org.au>
References: <552673196.20111109103207@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-security-module@vger.kernel.org, adobriyan@gmail.com,
	peter.p.waskiewicz.jr@intel.com
To: Daniil Stolnikov <danila.st@mail.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552673196.20111109103207@mail.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniil Stolnikov <danila.st@mail.ru> wrote:
>> Like I said, if you want address ranges, ask the userland IPSEC daemon
>> authors to synthesize it.
> 
> In this letter, the mailing list http://marc.info/?l=strongswan-users&m=130613736616488&w=4 strongswan-users say that their product has support for IP ranges, but the stack of Linux is based on network masks. So I do not understand how this would work without the support at the kernel level? How will coordination of policies?

Simple, you break a range policy into parts that can be expressed
as network/mask and install multiple policies.  The actual policies
in the kernel just has to have the same effect as the one you
negotiated with the other side, it does not have to look the same.

This is also why you can do the same thing with masks + netfilter.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
