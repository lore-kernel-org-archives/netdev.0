From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net: fec: enable pause frame to improve
 rx prefomance for 1G network
Date: Tue, 08 Jan 2013 17:58:50 -0800 (PST)
Message-ID: <20130108.175850.1601684784999646243.davem@davemloft.net>
References: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912Ab3AIB6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:58:51 -0500
In-Reply-To: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As others have mentioned, this is definitely something which must be
automatically detected via PHY autonegotiation results or the user
forcing the setting via ethtool.  Not like this.
