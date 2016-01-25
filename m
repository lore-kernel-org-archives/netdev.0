From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: make driver endian-safe
Date: Mon, 25 Jan 2016 10:52:05 -0800 (PST)
Message-ID: <20160125.105205.21234504326711935.davem@davemloft.net>
References: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org, l.stach@pengutronix.de,
	B38611@freescale.com, arnd@arndb.de, shawnguo@kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757402AbcAYSwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:52:06 -0500
In-Reply-To: <1453650757-27459-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 24 Jan 2016 16:52:37 +0100

> The driver treats the device descriptors as CPU-endian, which appears
> to be correct with the default endianness on both ARM (typically LE)
> and PowerPC (typically BE) SoCs, indicating that the hardware block
> is generated differently. Add endianness annotations and byteswaps as
> necessary.
> 
> It's not clear that the ifdef there really is correct and shouldn't
> just be #ifdef CONFIG_ARM, but I also can't test on anything but the
> i.MX6 HummingBoard where this gets it working with a BE kernel.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied.
