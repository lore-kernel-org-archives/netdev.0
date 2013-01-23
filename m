From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] net: fec: add napi support to improve
 proformance
Date: Wed, 23 Jan 2013 02:52:40 -0500 (EST)
Message-ID: <20130123.025240.1835436694088754169.davem@davemloft.net>
References: <1358914330-3768-1-git-send-email-Frank.Li@freescale.com>
	<20130123072635.GO1906@pengutronix.de>
	<CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, Frank.Li@freescale.com,
	shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab3AWHwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 02:52:44 -0500
In-Reply-To: <CAHrpEqQ3-prqJaCmt1hfOr4GzDVyuRNvko1SCyQZHdALhHkhkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


NAPI should not be configurable, all device drivers should be NAPI
only.
