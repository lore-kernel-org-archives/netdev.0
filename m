From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 8139cp: Call __cp_set_rx_mode() from
 cp_tx_timeout()
Date: Sun, 20 Sep 2015 22:24:19 -0700 (PDT)
Message-ID: <20150920.222419.405045524676501807.davem@davemloft.net>
References: <1442531948.97487.8.camel@infradead.org>
	<1442532114.97487.11.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbbIUFYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:24:20 -0400
In-Reply-To: <1442532114.97487.11.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 18 Sep 2015 00:21:54 +0100

> Unless we reset the RX config, on real hardware I don't seem to receive
> any packets after a TX timeout.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
