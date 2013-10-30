From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: if_arp: add ARPHRD_RAWIP type
Date: Wed, 30 Oct 2013 17:25:56 -0400 (EDT)
Message-ID: <20131030.172556.454916501978452298.davem@davemloft.net>
References: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
	<1383124271-15290-2-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jukka.rissanen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab3J3VZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:25:57 -0400
In-Reply-To: <1383124271-15290-2-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Date: Wed, 30 Oct 2013 11:11:10 +0200

> This is used when there is no L2 header before IP header.
> Example of this is Bluetooth 6LoWPAN network.
> 
> The RAWIP header type value is already used in some Android kernels
> so same value is used here in order not to break userspace.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>

I'm not applying patches like this until there is an actual user,
and this therefore goes for patch #2 as well.
