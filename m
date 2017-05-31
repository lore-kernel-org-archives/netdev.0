From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Fix xmit_more with BQL.
Date: Tue, 30 May 2017 22:38:00 -0400 (EDT)
Message-ID: <20170530.223800.599084258636099218.davem@davemloft.net>
References: <1496188980-13392-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdEaCvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 22:51:22 -0400
In-Reply-To: <1496188980-13392-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 30 May 2017 20:03:00 -0400

> We need to write the doorbell if BQL has stopped the queue and
> skb->xmit_more is set.  Otherwise it is possible for the tx queue to
> rot and cause tx timeout.
> 
> Fixes: 4d172f21cefe ("bnxt_en: Implement xmit_more.")
> Suggested-by: Yuval Mintz <yuval.mintz@cavium.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied, thanks.
