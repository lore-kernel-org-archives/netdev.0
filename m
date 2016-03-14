From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at803x: fix suspend/resume for SGMII link
Date: Sun, 13 Mar 2016 22:37:22 -0400 (EDT)
Message-ID: <20160313.223722.1488476549568744497.davem@davemloft.net>
References: <1457706713-13779-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	chunkeey@googlemail.com
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138AbcCNChY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:37:24 -0400
In-Reply-To: <1457706713-13779-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Fri, 11 Mar 2016 15:31:53 +0100

> When operating the at803x in SGMII mode, resuming the chip
> from power down brings up the copper-side link but leaves
> the SGMII link in unconnected state (tested with at8031
> attached to gianfar). In effect, this caused a permanent
> link loss once the related interface was put down.
> 
> This patch ensures that power down handling in supspend()
> and resume() is also applied to the SGMII link.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Applied, thanks.
