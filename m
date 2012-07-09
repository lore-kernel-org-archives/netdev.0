From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] be2net: Fix Endian
Date: Mon, 09 Jul 2012 00:14:54 -0700 (PDT)
Message-ID: <20120709.001454.1100101457356299928.davem@davemloft.net>
References: <1341453942-4198-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, somnath.kotur@emulex.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449Ab2GIHOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:14:55 -0400
In-Reply-To: <1341453942-4198-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu,  5 Jul 2012 10:05:42 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ETH_P_IP is host Endian, skb->protocol is big Endian, when
> compare them, we should change ETH_P_IP from host endian
> to big endian, htons, not ntohs.
> 
> CC: Somnath Kotur <somnath.kotur@emulex.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied to net-next since this actually doesn't cause any real
problems winc htons() and ntohs() are implemented identically
and perform the same operation.

Thanks.
