From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: cpsw: Use net_device_stats from struct
 net_device
Date: Mon, 10 Mar 2014 21:54:06 -0400 (EDT)
Message-ID: <20140310.215406.1145985583181167513.davem@davemloft.net>
References: <1394453543-30094-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, bigeasy@linutronix.de, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbaCKByI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 21:54:08 -0400
In-Reply-To: <1394453543-30094-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 10 Mar 2014 13:12:23 +0100

> Instead of using an own copy of struct net_device_stats in struct
> cpsw_priv, use stats from struct net_device. Also remove the thus
> unnecessary .ndo_get_stats function, as it just returns dev->stats,
> which is the default.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
