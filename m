From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix build when BNX2X_SRIOV is not enabled
Date: Tue, 13 May 2014 13:09:04 -0400 (EDT)
Message-ID: <20140513.130904.491541552382684334.davem@davemloft.net>
References: <536E7112.4080506@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaEMRJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:09:06 -0400
In-Reply-To: <536E7112.4080506@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 10 May 2014 11:33:54 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix build when BNX2X_SRIOV is not enabled.
> Change one parameter struct from bnx2 to bnx2x and don't return a value
> from a void function.
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:48: warning: 'struct bnx2' declared inside parameter list [enabled by default]
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:48: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:60: warning: 'return' with a value, in function returning void [enabled by default]
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
