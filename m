From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23 RESEND] cxgb3 - Fix dev->priv usage
Date: Fri, 24 Aug 2007 23:58:32 -0400
Message-ID: <46CFA8E8.90101@garzik.org>
References: <20070823220628.9835.73819.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50763 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217AbXHYD6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 23:58:38 -0400
In-Reply-To: <20070823220628.9835.73819.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> cxgb3 used netdev_priv() and dev->priv for different purposes.
> In 2.6.23, netdev_priv() == dev->priv, cxgb3 needs a fix.
> This patch is a partial backport of Dave Miller's changes in the 
> net-2.6.24 git branch. 
> 
> Without this fix, cxgb3 crashes on 2.6.23.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/adapter.h       |   10 +++
>  drivers/net/cxgb3/cxgb3_main.c    |  126 +++++++++++++++++++++----------------
>  drivers/net/cxgb3/cxgb3_offload.c |    6 +-
>  drivers/net/cxgb3/sge.c           |   23 ++++---
>  drivers/net/cxgb3/t3cdev.h        |    3 -
>  5 files changed, 100 insertions(+), 68 deletions(-)
> 

applied


