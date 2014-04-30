From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V7 net-next 1/7] xen-netback: Move grant_copy_op array
 back into struct xenvif.
Date: Wed, 30 Apr 2014 15:50:04 +0100
Message-ID: <20140430145004.GB19082@zion.uk.xensource.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
 <1398778035-26233-2-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37647 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933685AbaD3OuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 10:50:05 -0400
Content-Disposition: inline
In-Reply-To: <1398778035-26233-2-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:27:09PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> This array was allocated separately in commit ac3d5ac2 due to it being
> very large, and a struct xenvif is allocated as the netdev_priv part of
> a struct net_device, i.e. via kmalloc() but falling back to vmalloc() if
> the initial alloc. fails.
> 
> In preparation for the multi-queue patches, where this array becomes
> part of struct xenvif_queue and is always allocated through vzalloc(),
> move this back into the struct xenvif.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Minor nit: should include the actual title of ac3d5ac2 in the commit log
