From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] phy: unmask link partner capabilities
Date: Tue, 25 Feb 2014 18:39:49 -0500 (EST)
Message-ID: <20140225.183949.1934571310087232103.davem@davemloft.net>
References: <1393316568-24891-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madalin.bucur@freescale.com,
	shaohui.xie@freescale.com, shruti@freescale.com
To: cristian.bercaru@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847AbaBYXjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:39:51 -0500
In-Reply-To: <1393316568-24891-1-git-send-email-cristian.bercaru@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <cristian.bercaru@freescale.com>
Date: Tue, 25 Feb 2014 10:22:48 +0200

> From: Cristian Bercaru <cristian.bercaru@freescale.com>
> 
> Masking the link partner's capabilities with local capabilities can be
> misleading in autonegotiation scenarios such as PAUSE frame
> autonegotiation.
> This patch calculates the join between the local capabilities and the
> link parner capabilities, when it determines the speed and duplex
> settings, but does not mask any of the link partner capabilities when
> it calculates PAUSE frame settings.
> 
> Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>

Applied, thank you.
