From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qca_spi: Fix possible race during probe
Date: Mon, 11 May 2015 11:01:40 -0400 (EDT)
Message-ID: <20150511.110140.524130793207607787.davem@davemloft.net>
References: <1431158289-27946-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.heimpold@i2se.com
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbbEKPBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:01:42 -0400
In-Reply-To: <1431158289-27946-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Sat,  9 May 2015 07:58:09 +0000

> Registering the netdev before setting the priv data is unsafe.
> So fix this possible race by setting the priv data first.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> Cc: <stable@vger.kernel.org> # v3.18+
> Fixes: 291ab06e (net: qualcomm: new Ethernet over SPI driver for QCA7000)

Applied, thanks.
