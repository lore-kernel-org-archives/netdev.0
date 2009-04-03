From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 09:11:25 +0800
Message-ID: <20090403011125.GA6557@gondor.apana.org.au>
References: <49D5018E.4040801@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: avi@redhat.com, ghaskins@novell.com, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52247 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751238AbZDCBLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 21:11:46 -0400
Content-Disposition: inline
In-Reply-To: <49D5018E.4040801@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori <anthony@codemonkey.ws> wrote:
>
> Anyway, if we're able to send this many packets, I suspect we'll be able 
> to also handle much higher throughputs without TX mitigation so that's 
> what I'm going to look at now.

Awesome! I'm prepared to eat my words :)

On the subject of TX mitigation, can we please set a standard
on how we measure it? For instance, do we bind the the backend
qemu to the same CPU as the guest, or do we bind it to a different
CPU that shares cache? They're two completely different scenarios
and I think we should be explicit about which one we're measuring.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
