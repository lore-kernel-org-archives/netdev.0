From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnxt_en: Fix "uninitialized variable" bug in TPA
 code path.
Date: Wed, 18 Jan 2017 17:02:10 -0500 (EST)
Message-ID: <20170118.170210.33431443283476815.davem@davemloft.net>
References: <1484708839-11745-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew.gospodarek@broadcom.com
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753218AbdARWCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 17:02:12 -0500
In-Reply-To: <1484708839-11745-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 17 Jan 2017 22:07:19 -0500

> In the TPA GRO code path, initialize the tcp_opt_len variable to 0 so
> that it will be correct for packets without TCP timestamps.  The bug
> caused the SKB fields to be incorrectly set up for packets without
> TCP timestamps, leading to these packets being rejected by the stack.
> 
> Reported-by: Andy Gospodarek <andrew.gospodarek@broadocm.com>
> Acked-by: Andy Gospodarek <andrew.gospodarek@broadocm.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied, thanks Andy.
