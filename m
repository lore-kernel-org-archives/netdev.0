From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next] 6lowpan: Moving generic parts into
 net/core/6lowpan.c
Date: Wed, 20 Nov 2013 14:58:04 -0500 (EST)
Message-ID: <20131120.145804.1422019512682969636.davem@davemloft.net>
References: <1384950849-1982-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.aring@gmail.com
To: jukka.rissanen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193Ab3KTT6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 14:58:06 -0500
In-Reply-To: <1384950849-1982-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Date: Wed, 20 Nov 2013 14:34:09 +0200

> Because the IEEE 802154 and Bluetooth 6LoWPAN share the IPv6
> header compression and uncompression code, the common code
> is moved to net/core/6lowpan.c file.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>

There is no reason to move this file out from net/ieee802154/

Just like ipv6 does, you can have a net/ieee802154/6lowpan_core.c
file and appropriate Kconfig/Makefile rules to split this functionality
out appropriately.
