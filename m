From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: add ethtool eeprom change/dump feature
Date: Tue, 03 Sep 2013 21:59:35 -0400 (EDT)
Message-ID: <20130903.215935.1007110179484647485.davem@davemloft.net>
References: <1377787491-2932-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	hayeswang@realtek.com, bhutchings@solarflare.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761587Ab3IDB7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 21:59:37 -0400
In-Reply-To: <1377787491-2932-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Thu, 29 Aug 2013 16:44:51 +0200

> This adds the ability to read and change EEPROM for 93C46/93C56 serial
> EEPROM. Two-Wire serial interface and SPI are not supported. (Do not
> even try this for SPI or other chips, it may break your hardware.)

Please block the operation on configurations, such as the aforementioned
SPI, where it won't work.
