From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Wed, 17 Dec 2008 23:34:49 +1100
Message-ID: <20081217123449.GA22773@gondor.apana.org.au>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx> <20081217122350.GA6480@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu SEGAUD <mathieu.segaud@regala.cx>, netdev@vger.kernel.org,
	kernel@gentoo.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34369 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760840AbYLQMe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 07:34:58 -0500
Content-Disposition: inline
In-Reply-To: <20081217122350.GA6480@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 12:23:50PM +0000, Jarek Poplawski wrote:
> On 10-12-2008 15:44, Mathieu SEGAUD wrote:
> > 
> > we are experiencing some "virtual" network interfaces problem, especially
> > with tun/tap devices and with bridges, which occasionally get stuck and
> > won't deregister and hang the destroying process for very long time.
> ...
> >  [<c0266b41>] netdev_run_todo+0xf7/0x19d
> >  [<f8a7f3c5>] br_del_bridge+0x48/0x4c [bridge]
> ...
> > (This one was obtained with kernel version 2.6.27.4)
> 
> I wonder if it's related but since it was originally reported for
> 2.6.24 kernel, and there was a substantial change around this in dst
> code, it would be very interresting to try 2.6.23 for this.

Another thing to try would be to see if it's still reproducible
with IPv6 disabled (assuming IPv6 was enabled to begin with).

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
