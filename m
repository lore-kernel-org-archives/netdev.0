From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] net: fec: return IRQ_HANDLED if
 fec_ptp_check_pps_event handled it
Date: Wed, 20 Sep 2017 15:47:52 -0700 (PDT)
Message-ID: <20170920.154752.2003065585651545898.davem@davemloft.net>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
        <1505867589-11784-3-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org, fabio.estevam@nxp.com,
        lznuaa@gmail.com
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41106 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbdITWrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:47:53 -0400
In-Reply-To: <1505867589-11784-3-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Tue, 19 Sep 2017 17:33:09 -0700

> fec_ptp_check_pps_event will return 1 if FEC_T_TF_MASK caused
> an interrupt. Don't return IRQ_NONE in this case.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Acked-by: Fugang Duan <fugang.duan@nxp.com>

Applied.
