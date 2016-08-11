From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Add 64 bit addressing support for GEM
Date: Wed, 10 Aug 2016 17:39:23 -0700 (PDT)
Message-ID: <20160810.173923.1161254761132296894.davem@davemloft.net>
References: <1470728753-12985-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	harinik@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
	anirudh@xilinx.com
To: harini.katakam@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbcHKAjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 20:39:25 -0400
In-Reply-To: <1470728753-12985-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Tue, 9 Aug 2016 13:15:53 +0530

> This patch adds support for 64 bit addressing and BDs.
> -> Enable 64 bit addressing in DMACFG register.
> -> Set DMA mask when design config register shows support for 64 bit addr.
> -> Add new BD words for higher address when 64 bit DMA support is present.
> -> Add and update TBQPH and RBQPH for MSB of BD pointers.
> -> Change extraction and updation of buffer addresses to use
> 64 bit address.
> -> In gem_rx extract address in one place insted of two and use a
> separate flag for RXUSED.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>

It's not the cleanest looking thing in the world with all of these
ifdefs, but I can't suggest anything better, so applied to net-next
thanks.
