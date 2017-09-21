From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RESEND][for 4.14] net: qcom/emac: add software
 control for pause frame mode
Date: Thu, 21 Sep 2017 15:19:45 -0700 (PDT)
Message-ID: <20170921.151945.96227936324656258.davem@davemloft.net>
References: <1505939573-17335-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWTp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:19:45 -0400
In-Reply-To: <1505939573-17335-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 20 Sep 2017 15:32:53 -0500

> The EMAC has the option of sending only a single pause frame when
> flow control is enabled and the RX queue is full.  Although sending
> only one pause frame has little value, this would allow admins to
> enable automatic flow control without having to worry about the EMAC
> flooding nearby switches with pause frames if the kernel hangs.
> 
> The option is enabled by using the single-pause-mode private flag.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

I guess this is fine.  Applied, thanks.
