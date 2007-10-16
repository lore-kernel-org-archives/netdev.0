From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Tue, 16 Oct 2007 22:35:05 +0800
Message-ID: <20071016143505.GA12640@gondor.apana.org.au>
References: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au> <4714CBAB.4090601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Mack <dmack@juniper.net>, davej@redhat.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: Eric Sandeen <sandeen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3011 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932967AbXJPOxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:53 -0400
Content-Disposition: inline
In-Reply-To: <4714CBAB.4090601@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 09:33:15AM -0500, Eric Sandeen wrote:
> 
> Hm... running 2.6.23-6.fc8, I've been through 30+ reboot cycles without
> a problem.  Before, I'd oops every 5 or so times I booted...
> 
> I now have another NIC in the box, disabled; I don't think that should
> be affecting anything?

Well the original problem was caused by spurious interrupts on
the IRQ line where your e100 is so it could well be sporadic.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
