From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: Correct probe sequence handling
Date: Tue, 29 Aug 2017 16:13:32 -0700 (PDT)
Message-ID: <20170829.161332.1279744093983010191.davem@davemloft.net>
References: <1504046592-24779-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        dnelson@redhat.com, patches@apm.com, qnguyen@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2XNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:13:33 -0400
In-Reply-To: <1504046592-24779-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Tue, 29 Aug 2017 15:43:12 -0700

> From: Quan Nguyen <qnguyen@apm.com>
> 
> The phy is connected at early stage of probe but not properly
> disconnected if error occurs.  This patch fixes the issue.
> 
> Also changing the return type of xgene_enet_check_phy_handle(),
> since this function always returns success.
> 
> Signed-off-by: Quan Nguyen <qnguyen@apm.com>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Applied, thank you.
