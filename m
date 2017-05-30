From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: FW upgrade fixes
Date: Tue, 30 May 2017 14:13:01 -0400 (EDT)
Message-ID: <20170530.141301.1813370528618872412.davem@davemloft.net>
References: <1496147766-12948-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, arjun@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdE3SNC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 14:13:02 -0400
In-Reply-To: <1496147766-12948-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 30 May 2017 18:06:06 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> Disable FW_OK flag while flashing Firmware. This will help to fix any
> potential mailbox timeouts during Firmware flash.
> 
> Grab new devlog parameters after Firmware restart. When we FLASH new
> Firmware onto an adapter, the new Firmware may have the Firmware Device Log
> located at a different memory address or have a different size for it.
> 
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2:
> -Fix spelling mistake, "send" -> "sent"

Applied.
