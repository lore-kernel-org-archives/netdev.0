From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TI Davinci EMAC : Fix Console Hang when bringing the
 interface down
Date: Sun, 15 Nov 2009 22:17:59 -0800 (PST)
Message-ID: <20091115.221759.210122830.davem@davemloft.net>
References: <1258026942-2947-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751734AbZKPGRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:17:43 -0500
In-Reply-To: <1258026942-2947-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan <srk@ti.com>
Date: Thu, 12 Nov 2009 17:25:42 +0530

> In the NAPI poll function(emac_poll), check for netif_running()
> is unnecassary. In addition to associated runtime overhead, it
> also results in a continuous softirq loop when the interface is
> brought down under heavy traffic(tested wit Traffic Generator).
> Once the interface is disabled, the poll function always returns
> zero(with the check for netif_running) and napi_complete() would
> never get called resulting in softirq loop.
> 
> Signed-off-by: Sriramakrishnan <srk@ti.com>
> Acked-by: Chaithrika U S <chaithrika@ti.com>

Applied to net-2.6
