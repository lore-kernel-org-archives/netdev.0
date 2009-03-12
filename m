From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 16:55:43 -0700
Message-ID: <20090312165543.5f0e356b@nehalam>
References: <200903121946.24847.rusty@rustcorp.com.au>
	<20090312.055235.56926675.davem@davemloft.net>
	<200903130809.49523.rusty@rustcorp.com.au>
	<200903131017.11572.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pktoss@gmail.com,
	dcbw@redhat.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47285 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbZCLXzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 19:55:53 -0400
In-Reply-To: <200903131017.11572.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2009 10:17:11 +1030
Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Friday 13 March 2009 08:09:49 Rusty Russell wrote:
> > On Thursday 12 March 2009 23:22:35 David Miller wrote:
> > > If the link is always on, you should make that explicit by providing
> > > a link state handler, and making sure it always returns true.
> > 
> > "If".  We've discussed adding a virtio_net feature to indicate link status,
> > which implies that it's *not* always on.
> 
> Actually, I've changed my mind.
> 
> Unlike a device which *has* a carrier which we can't detect, there's no
> virtio_net "device" which can turn off link (not kvm/qemu, not lguest) without
> the pending VIRTIO_NET_S_LINK feature.
> 

Yes, need that feature, it is really useful for testing.
It is about the only reason I hold onto using VMware.
