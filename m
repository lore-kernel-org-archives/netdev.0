From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: greth_set_mac_add would corrupt the MAC address.
Date: Mon, 04 Jul 2011 21:39:21 -0700 (PDT)
Message-ID: <20110704.213921.1356899819484545509.davem@davemloft.net>
References: <1309770483-16026-1-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristoffer@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab1GEEj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:39:26 -0400
In-Reply-To: <1309770483-16026-1-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristoffer Glembo <kristoffer@gaisler.com>
Date: Mon,  4 Jul 2011 11:08:03 +0200

> The MAC address was set using the signed char sockaddr->sa_addr
> field and thus the address could be corrupted through sign extension.
> 
> Signed-off-by: Kristoffer Glembo <kristoffer@gaisler.com>

Applied, thanks!
