From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] cxgb3 - fix skb->dev dereference
Date: Wed, 20 Jun 2007 19:17:13 -0400
Message-ID: <4679B579.6040208@garzik.org>
References: <20070530170128.22789.3485.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45646 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611AbXFTXRP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:17:15 -0400
In-Reply-To: <20070530170128.22789.3485.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> eth_type_trans() now sets skb->dev. 
> References to skb->dev should happen after it is called.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/sge.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied 1-5 to #upstream-fixes (2.6.22)


