From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net:ethernet:samsung:initialize cur_rx_qnum
Date: Fri, 9 Dec 2016 23:42:03 +0100
Message-ID: <20161209224203.GA8878@electric-eye.fr.zoreil.com>
References: <1481285645-6028-1-git-send-email-rayagond.kokatanur@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: siva.kallam@samsung.com, bh74.an@samsung.com, ks.giri@samsung.com,
        vipul.pandya@samsung.com, netdev@vger.kernel.org
To: Rayagond Kokatanur <rayagond.kokatanur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41633 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbcLIWmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 17:42:11 -0500
Content-Disposition: inline
In-Reply-To: <1481285645-6028-1-git-send-email-rayagond.kokatanur@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rayagond Kokatanur <rayagond.kokatanur@gmail.com> :
> This patch initialize the cur_rx_qnum upon occurence of rx interrupt,
> without this initialization driver will not work with multiple rx queues
> configurations.
> 
> NOTE: This patch is not tested on actual hw.

(your patch should include a Signed-off-by)

Imho the driver needs more changes to support multiple rx queues.

- rx interrupt for queue A -> priv->cur_rx_qnum = A
- rx interrupt for queue B -> priv->cur_rx_qnum = B
- rx napi processing       -> Err...

Please start turning priv->cur_rx_qnum into a SXGBE_RX_QUEUES sized bitmap.

-- 
Ueimor
