From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid entry point
Date: Mon, 11 Feb 2008 15:02:12 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770305A83E@nekter>
References: <Pine.GSO.4.10.10802061527330.18812-100000@guinness> <47B0740B.5040006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:36200 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755984AbYBKUEH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 15:04:07 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47B0740B.5040006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reply inline -

> Subject: Re: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid
entry
> point
> 
> Sreenivasa Honnur wrote:
> > - Added s2io_vlan_rx_kill_vid entry point function for unregistering
> vlan.
> > - Fix to aggregate vlan packets. IP offset is incremented by
> >   4 bytes if the packet contains vlan header.
> > - resubmit for 2.6.24 kernel
> >
> > Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> 
> it's difficult to sort through these patches, because they clash a bit
> with the kernel development model.
> 
> You always need to send against the latest kernel (generally davem's
> tree if it's during -rc bug fix cycle, or linus's otherwise).
[Ram] Got it. We thought the window was still open for 2.6.24...

> 
> Once the changes are in place, then email the commit ids or backported
> patches to stable@kernel.org for inclusion in an already-released
kernel.
> 
> In this case, 2.6.24 was well on its way to being released weeks ago,
> when this set of patches was last resend (and then I subsequently
> screwed up, and apparently applied a wrong patch, as discussed)
> 
> So what we need are patches against the latest kernel
> (torvalds/linux-2.6.git), and after those are applied, email
> stable@kernel.org with whatever you want in 2.6.24.x.
[Ram] We will recreate these patches (with fixes and features) based on
torvalds/linux-2.6.git, and then send the fixes alone to
stable@kernel.org for 2.6.24.x.

Thanks,
Ram
> 
> 	Jeff
> 
> 

