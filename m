From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23] cxgb3 - Fix dev->priv usage
Date: Mon, 13 Aug 2007 13:58:11 -0700 (PDT)
Message-ID: <20070813.135811.06543390.davem@davemloft.net>
References: <20070813193303.15321.49171.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966422AbXHMU6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 16:58:12 -0400
In-Reply-To: <20070813193303.15321.49171.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 13 Aug 2007 12:33:04 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> cxgb3 used netdev_priv() and dev->priv for different purposes.
> In 2.6.23, netdev_priv() == dev->priv, cxgb3 needs a fix.
> This patch is a partial backport of Dave Miller's changes in the 
> net-2.6.24 git branch. 
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Thank you for doing this backport.
