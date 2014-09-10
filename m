From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 1/1] drivers: net: cpsw: dual_emac: fix reducing
 of rx descriptor during ifdown
Date: Wed, 10 Sep 2014 13:59:56 -0700 (PDT)
Message-ID: <20140910.135956.1279579323480837242.davem@davemloft.net>
References: <1410347289-3555-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaIJU75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:59:57 -0400
In-Reply-To: <1410347289-3555-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 10 Sep 2014 16:38:09 +0530

> In Dual EMAC, when both interface are up and while doing ifdown with heavy
> traffic then skbs already processed by DMA from that slave emac has to be
> requeued as still the other interface is up and running.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied.
