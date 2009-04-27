From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Mon, 27 Apr 2009 10:48:37 +0930
Message-ID: <200904271048.38401.rusty@rustcorp.com.au>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com> <20090420120930.GA4941@gondor.apana.org.au> <20090420122137.GA6768@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51811 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476AbZD0BSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2009 21:18:43 -0400
In-Reply-To: <20090420122137.GA6768@dhcp-1-124.tlv.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2009 09:51:38 pm Michael S. Tsirkin wrote:
> On Mon, Apr 20, 2009 at 08:09:30PM +0800, Herbert Xu wrote:
> > Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > Note: I started out just allocating and copying the iovec rather than adding
> > > yet another skb-iterating routine, but this turned out to add small but
> > > measurable overhead on data path: tx time per packet jumped from 6500 to 6700 ns
> > > (let me know if you want to see that version of the patch).
> > 
> > Can you please post the copying version as well so we can compare?
> 
> Sure. Here it is: much smaller, but slightly slower.

Which could probably be fixed by using an on-stack version for a iovec
of less than a certain size...

Cheers,
Rusty.
