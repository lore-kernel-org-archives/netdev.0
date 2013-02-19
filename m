From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: use netdev_alloc_skb_ip_align()
Date: Tue, 19 Feb 2013 00:54:02 -0500 (EST)
Message-ID: <20130219.005402.396031952782939015.davem@davemloft.net>
References: <1361220596-26478-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502Ab3BSFyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:54:03 -0500
In-Reply-To: <1361220596-26478-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Mon, 18 Feb 2013 21:49:56 +0100

> Without this patch b44 always allocates the 2 bytes needed for aligned
> access on every platform, now it uses netdev_alloc_skb_ip_align().
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied.
