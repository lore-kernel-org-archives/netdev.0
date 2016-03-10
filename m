From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 1/3] xen-netback: re-import canonical netif
 header
Date: Thu, 10 Mar 2016 17:23:41 +0000
Message-ID: <20160310172341.GQ31271@citrix.com>
References: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
 <1457613028-10381-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25229 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbcCJRXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:23:36 -0500
Content-Disposition: inline
In-Reply-To: <1457613028-10381-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 12:30:26PM +0000, Paul Durrant wrote:
> The canonical netif header (in the Xen source repo) and the Linux variant
> have diverged significantly. Recently much documentation has been added to
> the canonical header which is highly useful for developers making
> modifications to either xen-netfront or xen-netback. This patch therefore
> re-imports the canonical header in its entirity.
> 
> To maintain compatibility and some style consistency with the old Linux
> variant, the header was stripped of its emacs boilerplate, and
> post-processed and copied into place with the following commands:
> 
> ed -s netif.h << EOF
> H
> ,s/NETTXF_/XEN_NETTXF_/g
> ,s/NETRXF_/XEN_NETRXF_/g
> ,s/NETIF_/XEN_NETIF_/g
> ,s/XEN_XEN_/XEN_/g
> ,s/netif/xen_netif/g
> ,s/xen_xen_/xen_/g
> ,s/^typedef.*$//g
> ,s/^    /${TAB}/g
> w
> $
> w
> EOF
> 
> indent --line-length 80 --linux-style netif.h \
> -o include/xen/interface/io/netif.h
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
