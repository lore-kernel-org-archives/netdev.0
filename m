From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netdev: broadcom: propagate error code
Date: Mon, 05 Dec 2016 13:26:45 -0500 (EST)
Message-ID: <20161205.132645.1122516124371851668.davem@davemloft.net>
References: <1480758977-4234-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, prashant.sreedharan@broadcom.com,
        sbaddipa@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbcLES0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:26:47 -0500
In-Reply-To: <1480758977-4234-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>
Date: Sat,  3 Dec 2016 17:56:17 +0800

> Function bnxt_hwrm_stat_ctx_alloc() always returns 0, even if the call
> to _hwrm_send_message() fails. It may be better to propagate the errors
> to the caller of bnxt_hwrm_stat_ctx_alloc().
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188661
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
