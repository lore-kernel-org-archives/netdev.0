From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: FW: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid entry point
Date: Sun, 3 Feb 2008 16:03:50 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702F1DB25@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:27050 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbYBCVFf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 16:05:35 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patches failed because they were applied on the 2.6.25 branch, while
they were meant for the 2.6.24 branch (upstream-linus).

Ram
> -----Original Message-----
> From: Ramkrishna Vepa
> Sent: Friday, February 01, 2008 11:01 AM
> To: 'Jeff Garzik'; Sreenivasa Honnur
> Cc: support
> Subject: RE: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid
entry
> point
> 
> > Sreenivasa Honnur wrote:
> > > - Added s2io_vlan_rx_kill_vid entry point function for
unregistering
> > vlan.
> > > - Fix to aggregate vlan packets. IP offset is incremented by
> > >   4 bytes if the packet contains vlan header.
> > >
> > > Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> > > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> >
> > applied 1-2, patch #3 failed to apply
> [Ram] This sequence of patches were meant for 2.6.24 (upstream-linus)
and
> patch #3 was only a version update -
> -#define DRV_VERSION "2.0.26.17"
> +#define DRV_VERSION "2.0.26.18"
> I just checked upstream-linus and the version is still 2.0.26.17. Any
idea
> why the patch failed?
> 
> Thanks,
> Ram
