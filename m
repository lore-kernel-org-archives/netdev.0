From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Wed, 24 Oct 2012 23:06:48 -0400 (EDT)
Message-ID: <20121024.230648.1888101216213031807.davem@davemloft.net>
References: <1351011300-26964-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1351011300-26964-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@wantstofly.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net,
	andrew@lunn.ch, gregory.clement@free-electrons.com,
	alior@marvell.com, maen@marvell.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757623Ab2JYDG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:06:56 -0400
In-Reply-To: <1351011300-26964-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue, 23 Oct 2012 18:54:57 +0200

> +	u32 cause_rx_tx[CONFIG_NR_CPUS];

Please use per-cpu variables instead of explicitly sized
arrays.
