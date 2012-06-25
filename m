From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] mac802154: add wpan device-class support
Date: Mon, 25 Jun 2012 16:37:37 -0700 (PDT)
Message-ID: <20120625.163737.1022623694199782589.davem@davemloft.net>
References: <1340631197-27691-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1340631197-27691-2-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767Ab2FYXhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:37:38 -0400
In-Reply-To: <1340631197-27691-2-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Mon, 25 Jun 2012 17:33:11 +0400

> +	list_for_each_entry_rcu(sdata, &priv->slaves, list)
> +	{
> +		if (sdata->type != IEEE802154_DEV_WPAN)
> +			continue;
> +
> +		sskb = skb_clone(skb, GFP_ATOMIC);
> +		if (sskb)
> +			mac802154_subif_frame(sdata, sskb);
> +	}

This is not the correct way to place braces.  It should be:

	x() {
	...
	}

not:

	x()
	{
	}
