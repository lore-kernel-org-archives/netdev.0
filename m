From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] asix: Rework reading from EEPROM
Date: Thu, 19 Jul 2012 10:50:25 -0700 (PDT)
Message-ID: <20120719.105025.1954172029358314227.davem@davemloft.net>
References: <1342693387-17945-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan@asix.com.tw, kernel@teksavvy.com,
	grundler@chromium.org
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab2GSRu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:50:26 -0400
In-Reply-To: <1342693387-17945-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Thu, 19 Jul 2012 12:23:06 +0200

> The current code for reading the EEPROM via ethtool in the asix
> driver has a few issues. It cannot handle odd length values
> (accesses must be aligned at 16 bit boundaries) and interprets the
> offset provided by ethtool as 16 bit word offset instead as byte offset.
> 
> The new code for asix_get_eeprom() introduced by this patch is
> modeled after the code in
> drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
> and provides read access to the entire EEPROM with arbitrary
> offsets and lengths.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied.
