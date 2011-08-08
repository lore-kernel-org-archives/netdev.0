From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: Add IPv6 support to the LG-VL600 LTE USB
 modem driver
Date: Sun, 07 Aug 2011 22:29:41 -0700 (PDT)
Message-ID: <20110807.222941.1783212172392022233.davem@davemloft.net>
References: <1312669694-28800-1-git-send-email-prox@prolixium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prox@prolixium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab1HHFaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:30:55 -0400
In-Reply-To: <1312669694-28800-1-git-send-email-prox@prolixium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Kamichoff <prox@prolixium.com>
Date: Sat,  6 Aug 2011 18:28:14 -0400

> The LG-VL600 LTE USB modem supports IPv6, but uses and expects an IPv4
> ethertype (0x800) for these packets instead of the standard 0x86dd.
> This patch peeks at the IP version in the L3 header and sets the
> ethertype appropriately for IPv6 packets.
> 
> Signed-off-by: Mark Kamichoff <prox@prolixium.com>

Applied, thanks.
