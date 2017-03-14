From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc/hdlc: fix two little issue
Date: Mon, 13 Mar 2017 21:54:13 -0700 (PDT)
Message-ID: <20170313.215413.75307787689050093.davem@davemloft.net>
References: <1489455513-19239-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaobo.xie@nxp.com, netdev@vger.kernel.org
To: qiang.zhao@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdCNEyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 00:54:15 -0400
In-Reply-To: <1489455513-19239-1-git-send-email-qiang.zhao@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhao Qiang <qiang.zhao@nxp.com>
Date: Tue, 14 Mar 2017 09:38:33 +0800

> 1. modify bd_status from u32 to u16 in function hdlc_rx_done,
> because bd_status register is 16bits
> 2. write bd_length register before writing bd_status register
> 
> Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>

Applied, thank you.
