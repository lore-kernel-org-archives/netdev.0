From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix the last transmit buffer descriptor
Date: Fri, 03 Jun 2016 19:32:41 -0400 (EDT)
Message-ID: <20160603.193241.762160469427537530.davem@davemloft.net>
References: <1464860188-47854-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: yangbo.lu@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbcFCXcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:32:43 -0400
In-Reply-To: <1464860188-47854-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yangbo Lu <yangbo.lu@nxp.com>
Date: Thu, 2 Jun 2016 17:36:28 +0800

> When the transmit hardware timestamping is enabled, an additional
> TxBD would be added and would be set as the last TxBD with TXBD_LAST
> and TXBD_INTERRUPT. However this has been broken by a patch recently.
> This made the software couldn't get transmit hardware timestamps and
> resulted in call trace. So, this patch is to fix this issue.
> 
> Fixes: 48963b4492e9 ("gianfar: Remove redundant ops for do_tstamp
>        from xmit()")
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>

Applied, thanks.
