From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] net: fec: only check queue 0 if RXF_0/TXF_0
 interrupt is set
Date: Wed, 20 Sep 2017 15:47:41 -0700 (PDT)
Message-ID: <20170920.154741.1211259333792686419.davem@davemloft.net>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org, fabio.estevam@nxp.com,
        lznuaa@gmail.com
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751973AbdITWrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:47:42 -0400
In-Reply-To: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Tue, 19 Sep 2017 17:33:07 -0700

> Before queue 0 was always checked if any queue caused an interrupt.
> It is better to just mark queue 0 if queue 0 has caused an interrupt.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Acked-by: Fugang Duan <Fugang.duan@nxp.com>

Applied.
