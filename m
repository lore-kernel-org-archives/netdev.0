From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/13] cxgb3 - use immediate data for offload Tx
Date: Tue, 14 Aug 2007 01:43:34 -0400
Message-ID: <46C14106.4080604@garzik.org>
References: <20070811062949.8076.42523.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46733 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S942275AbXHNFng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:43:36 -0400
In-Reply-To: <20070811062949.8076.42523.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Send small TX_DATA work requests as immediate data even when
> there are fragments.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/sge.c |   17 +++++++++++------
>  1 files changed, 11 insertions(+), 6 deletions(-)

needs additional explanation.  don't just describe the new post-change 
behavior, describe why this change is needed.


