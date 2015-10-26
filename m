From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 1/8] xen-netback: re-import canonical netif
 header
Date: Mon, 26 Oct 2015 17:05:20 +0000
Message-ID: <20151026170520.GB18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14380 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbJZRGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:06:17 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:18AM +0100, Paul Durrant wrote:
> The canonical netif header (in the Xen source repo) and the Linux variant
> have diverged significantly. Recently much documentation has been added to
> the canonical header and new definitions and types to support packet hash
> configuration. Subsequent patches in this series add support for packet
> hash configuration in xen-netback so this patch re-imports the canonical
> header in readiness.
> 
> To maintain compatibility and some style consistency with the old Linux
> variant, the header was stripped of its emacs boilerplate, and
> post-processed and copied into place with the following commands:
> 
> ed -s netif.h << EOF
> H
> ,s/NETTXF_/XEN_NETTXF_/g
> ,s/NETRXF_/XEN_NETRXF_/g
> ,s/NETIF_RSP/XEN_NETIF_RSP/g
> ,s/netif_tx/xen_netif_tx/g
> ,s/netif_rx/xen_netif_rx/g
> ,s/netif_extra_info/xen_netif_extra_info/g
> w
> EOF
> 
> indent --linux-style netif.h -o include/xen/interface/io/netif.h
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
> 
> Whilst awaiting review of my patches to the canonical netif.h, import has
> been done from my staging branch using:
> 
> wget http://xenbits.xen.org/gitweb/?p=people/pauldu/xen.git;a=blob_plain;f=xen/include/public/io/netif.h;hb=refs/heads/netif

There is on-going discussion on this so I'm going to skip this patch for
now.

Wei.
