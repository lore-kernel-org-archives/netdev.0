From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and avoid TX queue overrun through packet drop
Date: Fri, 25 Mar 2011 15:21:54 +1030
Message-ID: <87k4fnls45.fsf@rustcorp.com.au>
References: <20110318133311.GA20623@gondor.apana.org.au> <1300498915.3441.21.camel@localhost.localdomain> <1300730587.3441.24.camel@localhost.localdomain> <20110322113649.GA17071@redhat.com> <1300847204.3441.26.camel@localhost.localdomain> <87r59xbbr6.fsf@rustcorp.com.au>  <20110324142822.GD12958@redhat.com> <1300988809.3441.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58698 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443Ab1CYLWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 07:22:04 -0400
In-Reply-To: <1300988809.3441.48.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2011 10:46:49 -0700, Shirley Ma <mashirle@us.ibm.com> wrote:
> On Thu, 2011-03-24 at 16:28 +0200, Michael S. Tsirkin wrote:
> > Several other things I am looking at, wellcome cooperation:
> > 1. It's probably a good idea to update avail index
> >    immediately instead of upon kick: for RX
> >    this might help parallelism with the host.
> Is that possible to use the same idea for publishing last used idx to
> publish avail idx? Then we can save guest iowrite/exits.

Yes, it should be symmetrical.  Test independently of course, but the
same logic applies.

Thanks!
Rusty.
