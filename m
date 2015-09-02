From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: add support for multicast control
Date: Wed, 2 Sep 2015 15:00:49 +0100
Message-ID: <20150902140049.GI18474@zion.uk.xensource.com>
References: <1441196393-26564-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60614 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbbIBOBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 10:01:07 -0400
Content-Disposition: inline
In-Reply-To: <1441196393-26564-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 01:19:53PM +0100, Paul Durrant wrote:
> Xen's PV network protocol includes messages to add/remove ethernet
> multicast addresses to/from a filter list in the backend. This allows
> the frontend to request the backend only forward multicast packets
> which are off interest thus preventing unnecessary noise on the shared

"of interest"

> ring.
> 
[...]
> +
> +void xenvif_mcast_flush(struct xenvif *vif)

Only one cosmetic comment.

My first impression of this function by looking at the name is that it
flushes queued multicast packets. Maybe we can rename it to
xenvif_mcast_addr_list_free ?

Wei.
