From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 17:16:39 +0800
Message-ID: <20090402091639.GA30126@gondor.apana.org.au>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ghaskins@novell.com, anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935512AbZDBJRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:17:00 -0400
Content-Disposition: inline
In-Reply-To: <49D47F11.6070400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 12:02:09PM +0300, Avi Kivity wrote:
>
> There is no choice.  Exiting from the guest to the kernel to userspace  
> is prohibitively expensive, you can't do that on every packet.

I was referring to the bit between the kernel and userspace.

In any case, I just looked at the virtio mitigation code again
and I am completely baffled at why we need it.  Look at Greg's
code or the netback/netfront notification, why do we need this
completely artificial mitigation when the ring itself provides
a natural way of stemming the flow?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
