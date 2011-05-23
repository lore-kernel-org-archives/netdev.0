From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: hash key for rss-config cmd not set
Date: Mon, 23 May 2011 15:52:06 -0400 (EDT)
Message-ID: <20110523.155206.345121915872826257.davem@davemloft.net>
References: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226Ab1EWTwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 15:52:13 -0400
In-Reply-To: <249a7eac-6aa7-481d-b7b0-a2a3b144963f@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 23 May 2011 17:55:27 +0530

> Need a random hash key to effectively hash incoming connections into
> multiple RX rings.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

You're saying you need a random hash key, yet you're assigning
a constant.

Why not use a real random number, via get_random() or similar?
