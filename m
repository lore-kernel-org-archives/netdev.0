From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 5/5] virtio_net: Add support for VLAN filtering in the
 hypervisor
Date: Tue, 20 Jan 2009 16:44:00 +0000
Message-ID: <1232469840.5277.10.camel@blaa>
References: <1232357520.5627.15.camel@blaa>
	 <20090120163636.10034.5080.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47313 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbZATQoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 11:44:16 -0500
In-Reply-To: <20090120163636.10034.5080.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 09:36 -0700, Alex Williamson wrote:
> VLAN filtering allows the hypervisor to drop packets from VLANs
> that we're not a part of, further reducing the number of extraneous
> packets recieved.  This makes use of the VLAN virtqueue command class.
> The ENABLE command is used both to activate the filter and verify the
> existence of the functionality on the backend.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Cool, looks good.

Acked-by: Mark McLoughlin <markmc@redhat.com>

Cheers,
Mark.

