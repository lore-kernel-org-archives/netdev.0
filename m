From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] virtio_net: Add support for VLAN filtering in the
 hypervisor
Date: Sun, 25 Jan 2009 18:08:12 -0800 (PST)
Message-ID: <20090125.180812.31889647.davem@davemloft.net>
References: <1232357520.5627.15.camel@blaa>
	<20090120163636.10034.5080.stgit@debian.lart>
	<1232469840.5277.10.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, kvm@vger.kernel.org
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42583
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753028AbZAZCIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 21:08:10 -0500
In-Reply-To: <1232469840.5277.10.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Tue, 20 Jan 2009 16:44:00 +0000

> On Tue, 2009-01-20 at 09:36 -0700, Alex Williamson wrote:
> > VLAN filtering allows the hypervisor to drop packets from VLANs
> > that we're not a part of, further reducing the number of extraneous
> > packets recieved.  This makes use of the VLAN virtqueue command class.
> > The ENABLE command is used both to activate the filter and verify the
> > existence of the functionality on the backend.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> 
> Cool, looks good.
> 
> Acked-by: Mark McLoughlin <markmc@redhat.com>

I'd like to make some forward progress on this patch set.
Either apply something, or defer to Rusty.

If you think I should apply it to net-next-2.6, please just
resubmit the serious with accumulated ACK'd etc.

Else I'll let these flow Rusty's way.
