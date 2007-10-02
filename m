From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/3][BNX2]: Add missing napi_disable() in
 bnx2_close().
Date: Tue, 02 Oct 2007 16:27:12 -0700 (PDT)
Message-ID: <20071002.162712.11079459.davem@davemloft.net>
References: <1191370989.5961.31.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755610AbXJBX1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 19:27:13 -0400
In-Reply-To: <1191370989.5961.31.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 02 Oct 2007 17:23:09 -0700

> [BNX2]: Add missing napi_disable() in bnx2_close().
> 
> bnx2_close() -> bnx2_netif_stop() will not call napi_disable() because
> the netif_state is not running in bnx2_close().  To avoid confusion,
> we change it to disable interrupt and napi directly in bnx2_close().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6.24
