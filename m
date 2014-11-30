From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Sun, 30 Nov 2014 16:21:06 +0800
Message-ID: <20141130082106.GA9531@gondor.apana.org.au>
References: <5478CC27.9040705@redhat.com>
 <20141128235935.GA2178@gondor.apana.org.au>
 <547954B9.2050804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48418 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbaK3IVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 03:21:10 -0500
Content-Disposition: inline
In-Reply-To: <547954B9.2050804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 29, 2014 at 03:08:09AM -0200, Marcelo Ricardo Leitner wrote:
> On 28-11-2014 21:59, Herbert Xu wrote:
> >On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
> >>
> >>I saw there are tun updates on Dave's queue but none seemed to handle this.
> >>
> >>I can't use current net-next
> >>(799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
> >>because tun got clogged somehow. Bisected down to:
> >>
> >>commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
> >>Author: Herbert Xu <herbert@gondor.apana.org.au>
> >>Date:   Fri Nov 7 21:22:23 2014 +0800
> >
> >Does this patch help?
> 
> Yay, it does! Works for me, thanks Herbert.
> I didn't test performance, but dhcp could get through.
> 
> Are you sure about the Fixes tag? Because bisect really pointed to e0b46d0ee9c.

Well according to your report you were having problems with
tun_get_user.  The bug I introduced was in tun_put_user and has
already been fixed by Jason Wang.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
