From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/7] sfc: Add channel specific receive_skb
 handler and post_remove callback
Date: Wed, 18 Jul 2012 11:32:56 -0700 (PDT)
Message-ID: <20120718.113256.279646201702165485.davem@davemloft.net>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
	<1342635600.2617.54.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	ajackson@solarflare.com, richardcochran@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab2GRSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:32:57 -0400
In-Reply-To: <1342635600.2617.54.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 18 Jul 2012 19:20:00 +0100

> +	void (*receive_skb)(struct efx_channel *, struct sk_buff *);

This looks to me like a conduit for proprietary features implemented
in a binary-only blob.

I understand how you're using here for PTP, but you're really openning
the door for things I really wouldn't be very happy about.
