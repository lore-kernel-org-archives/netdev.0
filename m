From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21 1/2] cxgb3 - Fix low memory conditions
Date: Thu, 19 Apr 2007 15:03:42 -0400
Message-ID: <4627BD0E.4070705@garzik.org>
References: <20070417180630.17050.15974.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59986 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766933AbXDSTDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 15:03:44 -0400
In-Reply-To: <20070417180630.17050.15974.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Reuse the incoming skb when a clientless abort req is recieved.
> 
> The release of RDMA connections HW resources might be deferred in
> low memory situations. 
> Ensure that no further activity is passed up to the RDMA driver
> for these connections.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_defs.h    |    5 ++-
>  drivers/net/cxgb3/cxgb3_offload.c |   69 +++++++++++++++++++++++++++----------
>  2 files changed, 55 insertions(+), 19 deletions(-)

applied 1-2


