From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 05/16] net: fec: reduce interrupts
Date: Wed, 06 Apr 2016 23:57:31 -0400 (EDT)
Message-ID: <20160406.235731.57253886354009409.davem@davemloft.net>
References: <1459909562-22865-6-git-send-email-troy.kisky@boundarydevices.com>
	<20160406.172008.266926707628676037.davem@davemloft.net>
	<5705AD07.10009@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbcDGD5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 23:57:38 -0400
In-Reply-To: <5705AD07.10009@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Wed, 6 Apr 2016 17:42:47 -0700

> Sure, that's an easy change. But if a TX int is what caused the
> interrupt and masks them, and then a RX packet happens before napi
> runs, do you want the TX serviced 1st, or RX ?

If you properly split your driver up into seperate interrupt/poll
instances, one for TX one for RX, you wouldn't need to ask me
that question now would you?

:-)
