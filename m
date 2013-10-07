From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] be2net: Warn users of possible broken
 functionality on BE2 cards with very old FW versions with latest driver
Date: Mon, 07 Oct 2013 12:31:16 -0400 (EDT)
Message-ID: <20131007.123116.1462434377931881914.davem@davemloft.net>
References: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756491Ab3JGQbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:31:18 -0400
In-Reply-To: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 3 Oct 2013 15:34:29 +0530

> +	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
> +		dev_err(dev, "Firmware version is too old.IRQs may not work\n");

So many grammatical mistakes in one line.

First sentence got a period, second one did not.

Missing space between period and second sentence.
