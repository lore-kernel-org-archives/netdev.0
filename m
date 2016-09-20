From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Fix build error for kernesl without
 RTC-LIB
Date: Tue, 20 Sep 2016 03:54:30 -0400 (EDT)
Message-ID: <20160920.035430.1975866470788831568.davem@davemloft.net>
References: <1474356993-5857-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752830AbcITHy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:54:56 -0400
In-Reply-To: <1474356993-5857-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 20 Sep 2016 03:36:33 -0400

> From: Rob Swindell <swindell@broadcom.com>
> 
> bnxt_hwrm_fw_set_time() now returns -EOPNOTSUPP when built for kernel
> without RTC_LIB.  Setting the firmware time is not critical to the
> successful completion of the firmware update process.
> 
> Signed-off-by: Rob Swindell <Rob.Swindell@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied.
