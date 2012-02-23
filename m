From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Thu, 23 Feb 2012 14:45:41 -0500 (EST)
Message-ID: <20120223.144541.1354349294973443529.davem@davemloft.net>
References: <4F46404D.10509@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2BWTpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 14:45:47 -0500
In-Reply-To: <4F46404D.10509@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 23 Feb 2012 15:34:05 +0200

> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

This is rediculious as a default, yes even for 10Gb.

Do you have any idea how high latency is going to be for packets
trying to get into the transmit queue if there are already a
thousand other frames in there?
