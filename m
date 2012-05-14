From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 02/13] mac802154: allocation of ieee802154
 device
Date: Mon, 14 May 2012 18:28:24 -0400 (EDT)
Message-ID: <20120514.182824.2287894454156614132.davem@davemloft.net>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1336831165-23944-3-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2ENW21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:28:27 -0400
In-Reply-To: <1336831165-23944-3-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Sat, 12 May 2012 17:59:14 +0400

> Add interface for device drivers to allocate and register ieee802154
> compatible device.
> 
> This code is based on net/mac80211/main.c file
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Sorry, this needs to be fixed up.

I can almost understand using a comment formatting style I
disagree with, if you do so consistently.

But formatting them in THREE completely different ways?  Give me a
break:

> +	/* As in mac80211 slaves list is modified:
> +	 * 1) under the RTNL
> +	 * 2) protected by slaves_mtx;
> +	 * 3) in an RCU manner
> +	 *
> +	 * So atomic readers can use any of this protection methods
> +	 */
 ...
> +	/* This one is used for scanning and other
> +	 * jobs not to be interfered with serial driver */
 ...
> +	/*
> +	 * The following flag is also modified under slaves_mtx and RTNL,
> +	 * so you can read them using any of protection methods.
> +	 */
> +	/*
> +	 * SoftMAC device is registered and running. One can add
> +	 * subinterfaces.
> +	 */

That's just beyond silly, and the last two comments are right next to
eachother just combine them to one.

Go over your entire patch set and make sure that all of your comments
are of the form:

	/* Like
	 * this.
	 */
