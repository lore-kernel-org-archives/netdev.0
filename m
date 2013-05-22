From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next 0/2 V2] Xen network: split event channels
 support
Date: Wed, 22 May 2013 09:35:59 +0100
Message-ID: <1369211759.21246.115.camel@zakaz.uk.xensource.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:11061 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3EVIgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 04:36:01 -0400
In-Reply-To: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 19:35 +0100, Wei Liu wrote:
> This series adds a new feature called split event channels.
> 
> In the original implementation, only one event channel is setup between
> frontend and backend. This is not ideal as TX notification interferes with RX
> notification. Using dedicated event channels for TX and RX solves this issue.
> 
> Changes since V1:
> * change subject lines of commits to be more specific
> * add parameter feature_split_event_channels for xen-netback
> * remove two dev_info
> 
> Wei Liu (2):
>   xen-netback: split event channels support for Xen backend driver
>   xen-netfront: split event channels support for Xen frontend driver
> 
>  drivers/net/xen-netback/common.h    |   13 ++-
>  drivers/net/xen-netback/interface.c |   84 ++++++++++++++---
>  drivers/net/xen-netback/netback.c   |   14 ++-
>  drivers/net/xen-netback/xenbus.c    |   40 ++++++--
>  drivers/net/xen-netfront.c          |  173 +++++++++++++++++++++++++++++------
>  5 files changed, 266 insertions(+), 58 deletions(-)

Please could you also submit a patch to xen.git against which documents
the new protocol and feature flags etc in the canonical
xen/include/public/io/netif.h header. This change should then be
synchronised into Linux's include/xen/interface/io/netif.h copy as part
of this series.

Ian.
