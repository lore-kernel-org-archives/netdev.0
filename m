From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2 net-next] xen-netback: add support for multicast
 control
Date: Wed, 2 Sep 2015 18:11:56 +0100
Message-ID: <20150902171155.GA30541@zion.uk.xensource.com>
References: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18775 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733AbbIBRL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 13:11:58 -0400
Content-Disposition: inline
In-Reply-To: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 05:58:36PM +0100, Paul Durrant wrote:
> Xen's PV network protocol includes messages to add/remove ethernet
> multicast addresses to/from a filter list in the backend. This allows
> the frontend to request the backend only forward multicast packets
> which are of interest thus preventing unnecessary noise on the shared
> ring.
> 
> The canonical netif header in git://xenbits.xen.org/xen.git specifies
> the message format (two more XEN_NETIF_EXTRA_TYPEs) so the minimal
> necessary changes have been pulled into include/xen/interface/io/netif.h.
> 
> To prevent the frontend from extending the multicast filter list
> arbitrarily a limit (XEN_NETBK_MCAST_MAX) has been set to 64 entries.
> This limit is not specified by the protocol and so may change in future.
> If the limit is reached then the next XEN_NETIF_EXTRA_TYPE_MCAST_ADD
> sent by the frontend will be failed with NETIF_RSP_ERROR.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
