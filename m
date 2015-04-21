From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] altera tse: Error-Bit on tx-avalon-stream always
 set.
Date: Mon, 20 Apr 2015 22:02:05 -0400 (EDT)
Message-ID: <20150420.220205.251689458027858902.davem@davemloft.net>
References: <1429568198-28064-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbbDUCCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 22:02:07 -0400
In-Reply-To: <1429568198-28064-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Tue, 21 Apr 2015 00:16:38 +0200

> From: Andreas Oetken <ennoerlangen@gmail.com>
> 
> The Error-Bit on the avalon streaming interface of the
> tx-dma-channel was always set. In SGMII configurations
> this leads to error-symbols on the PCS and packet-rejection
> on the receiver side (e.g. SGMII/1000Base-X connected switch).
> 
> This only applies to the tse-configuration with MSGDMA.
> 
> This issue was detected and fixed on a custom board with
> a direct connection to a Marvell switch in SGMII-PHY-Mode.
> (incl. custom patches for SGMII-PCS).
> 
> According to the datasheet if ff_tx_err (avalon-streaming)
> is set it is forwarded to gm_tx_err. As a result the PCS
> is forwarding the error by sending a "/V/"-caracter.
> 
> Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>

Applied.
