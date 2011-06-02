From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 12:59:05 -0700 (PDT)
Message-ID: <20110602.125905.1328730502619772466.davem@davemloft.net>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
	<1307039753.2812.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754330Ab1FBUAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:00:19 -0400
In-Reply-To: <1307039753.2812.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Jun 2011 19:35:53 +0100

> So far as I can see, this has no effect, because dev_queue_xmit() always
> sets queue_mapping (in dev_pick_tx()).

__skb_tx_hash() uses any hash value recorded in the SKB before trying
to manually it.
