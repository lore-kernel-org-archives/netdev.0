From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/14] mac802154: basic ieee802.15.4 device structures
Date: Mon, 19 Dec 2011 14:32:48 -0500 (EST)
Message-ID: <20111219.143248.1789452356925299625.davem@davemloft.net>
References: <20111219163117.GA13123@avtobot.cybertron>
	<1324312434-13151-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab1LSTdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 14:33:00 -0500
In-Reply-To: <1324312434-13151-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Mon, 19 Dec 2011 19:33:41 +0300

> +struct ieee802154_hw_addr_filt {
> +	u16 pan_id;
> +	u16 short_addr;
> +	u8 ieee_addr[IEEE802154_ADDR_LEN];
> +	u8 pan_coord;
> +};

What is the endianness of pan_id and short_addr objects?  You should use
the appropriate endianness types "__be16, __le16" and accessors to
represent this.

If you're storing them in cpu byte order, why?
