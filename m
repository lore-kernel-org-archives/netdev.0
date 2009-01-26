From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH 5/5] virtio_net: Add support for VLAN filtering in the
 hypervisor
Date: Mon, 26 Jan 2009 10:42:28 -0700
Message-ID: <1232991748.7026.87.camel@lappy>
References: <1232357520.5627.15.camel@blaa>
	 <20090120163636.10034.5080.stgit@debian.lart>
	 <1232469840.5277.10.camel@blaa>
	 <20090125.180812.31889647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au,
	kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:46319 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbZAZRl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:41:56 -0500
In-Reply-To: <20090125.180812.31889647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-25 at 18:08 -0800, David Miller wrote:
> From: Mark McLoughlin <markmc@redhat.com>
> Date: Tue, 20 Jan 2009 16:44:00 +0000
> 
> > On Tue, 2009-01-20 at 09:36 -0700, Alex Williamson wrote:
> > > VLAN filtering allows the hypervisor to drop packets from VLANs
> > > that we're not a part of, further reducing the number of extraneous
> > > packets recieved.  This makes use of the VLAN virtqueue command class.
> > > The ENABLE command is used both to activate the filter and verify the
> > > existence of the functionality on the backend.
> > > 
> > > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> > 
> > Cool, looks good.
> > 
> > Acked-by: Mark McLoughlin <markmc@redhat.com>
> 
> I'd like to make some forward progress on this patch set.
> Either apply something, or defer to Rusty.
> 
> If you think I should apply it to net-next-2.6, please just
> resubmit the serious with accumulated ACK'd etc.
> 
> Else I'll let these flow Rusty's way.

I'd still like to see if Rusty has any comments now that he's hopefully
catching up after LCA.  I'll resend them in a couple days if not.
Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

