From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] xen-netback: add support for multicast
 control
Date: Wed, 02 Sep 2015 11:45:35 -0700 (PDT)
Message-ID: <20150902.114535.1282750973309097658.davem@davemloft.net>
References: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbIBSpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:45:36 -0400
In-Reply-To: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 2 Sep 2015 17:58:36 +0100

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

Applied.
