From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlx4_en: Fix BQL reset TX queue call point
Date: Thu, 07 Feb 2013 23:34:20 -0500 (EST)
Message-ID: <20130207.233420.735697309600979008.davem@davemloft.net>
References: <alpine.DEB.2.00.1302060955490.26438@pokey.mtv.corp.google.com>
	<51134F33.1030007@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, yevgenyp@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757902Ab3BHEeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:34:22 -0500
In-Reply-To: <51134F33.1030007@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 7 Feb 2013 08:52:35 +0200

> On 06/02/2013 19:58, Tom Herbert wrote:
>> Fix issue in Mellanox driver related to BQL.  netdev_tx_reset_queue
>> was not being called in certain situations where the device was
>> being start and stopped.  Moved netdev_tx_reset_queue from the reset
>> device path to mlx4_en_free_tx_buf which is where the rings are
>> cleaned in a reset (specifically from device being stopped).
>> 
>> Signed-off-by: Tom Herbert <therbert@google.com>
...
> Acked-By: Amir Vadai <amirv@mellanox.com>

Applied to net-next, thanks.
