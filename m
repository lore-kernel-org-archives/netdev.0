From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: qca_spi: clear IFF_TX_SKB_SHARING
Date: Thu, 25 Feb 2016 16:14:42 -0500 (EST)
Message-ID: <20160225.161442.852490399971858395.davem@davemloft.net>
References: <1456255404-8668-1-git-send-email-stefan.wahren@i2se.com>
	<1456255404-8668-2-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbcBYVOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:14:44 -0500
In-Reply-To: <1456255404-8668-2-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 23 Feb 2016 19:23:24 +0000

> ether_setup sets IFF_TX_SKB_SHARING but this is not supported by
> qca_spi as it modifies the skb on xmit.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> Fixes: 291ab06ecf67 (net: qualcomm: new Ethernet over SPI driver for QCA7000)

Applied and queued up for -stable.
