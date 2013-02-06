From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlx4_en: Fix BQL reset TX queue call point
Date: Wed, 06 Feb 2013 16:11:55 -0500 (EST)
Message-ID: <20130206.161155.87531449769666222.davem@davemloft.net>
References: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758462Ab3BFVL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:11:57 -0500
In-Reply-To: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 6 Feb 2013 09:58:41 -0800 (PST)

> Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
> was not being called in certain situations where the device was
> being start and stopped.  Moved netdev_tx_reset_queue from the reset
> device path to mlx4_en_free_tx_buf which is where the rings are
> cleaned in a reset (specifically from device being stopped).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Mellanox folks, please review.
