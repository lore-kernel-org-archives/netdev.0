From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt: do not busy-poll when link is down
Date: Thu, 24 Nov 2016 15:40:05 -0500 (EST)
Message-ID: <20161124.154005.944121181562755910.davem@davemloft.net>
References: <1479838448-44877-1-git-send-email-gospo@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: gospo@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756748AbcKXUkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 15:40:08 -0500
In-Reply-To: <1479838448-44877-1-git-send-email-gospo@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@broadcom.com>
Date: Tue, 22 Nov 2016 13:14:08 -0500

> When busy polling while a link is down (during a link-flap test), TX
> timeouts were observed as well as the following messages in the ring
> buffer:
> 
> bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
> bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free tx failed. rc:-1
> bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
> bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free rx failed. rc:-1
> 
> These were resolved by checking for link status and returning if link
> was not up.
> 
> Signed-off-by: Andy Gospodarek <gospo@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> Tested-by: Rob Miller <rob.miller@broadcom.com>

Applied.
