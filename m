From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 00/13] Persistent grant maps for xen net drivers
Date: Tue, 19 May 2015 16:39:01 +0100
Message-ID: <20150519153901.GH26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37521 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbESPjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 11:39:10 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:24PM +0200, Joao Martins wrote:

> There have been recently[3] some discussions and issues raised on
> persistent grants for the block layer, though the numbers above
> show some significant improvements specially on more network intensive
> workloads and provide a margin for comparison against future map/unmap
> improvements.
> 
> Any comments or suggestions are welcome,
> Thanks!

Thanks, the numbers certainly look interesting.

I'm just a bit concerned about the complexity of netback. I've
commented on individual patches, we can discuss the issues there.

Wei.

> Joao
> 
> [1] http://article.gmane.org/gmane.linux.network/249383
> [2] http://bit.ly/1IhJfXD
> [3] http://lists.xen.org/archives/html/xen-devel/2015-02/msg02292.html
> 
> Joao Martins (13):
>   xen-netback: add persistent grant tree ops
>   xen-netback: xenbus feature persistent support
>   xen-netback: implement TX persistent grants
>   xen-netback: implement RX persistent grants
>   xen-netback: refactor xenvif_rx_action
>   xen-netback: copy buffer on xenvif_start_xmit()
>   xen-netback: add persistent tree counters to debugfs
>   xen-netback: clone skb if skb->xmit_more is set
>   xen-netfront: move grant_{ref,page} to struct grant
>   xen-netfront: refactor claim/release grant
>   xen-netfront: feature-persistent xenbus support
>   xen-netfront: implement TX persistent grants
>   xen-netfront: implement RX persistent grants
> 
>  drivers/net/xen-netback/common.h    |  79 ++++
>  drivers/net/xen-netback/interface.c |  78 +++-
>  drivers/net/xen-netback/netback.c   | 873 ++++++++++++++++++++++++++++++------
>  drivers/net/xen-netback/xenbus.c    |  24 +
>  drivers/net/xen-netfront.c          | 362 ++++++++++++---
>  5 files changed, 1216 insertions(+), 200 deletions(-)
> 
> -- 
> 2.1.3
