From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Sun, 22 Jul 2012 14:54:54 -0700 (PDT)
Message-ID: <20120722.145454.943592825984584407.davem@davemloft.net>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kgroeneveld@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab2GVVyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 17:54:55 -0400
In-Reply-To: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Groeneveld <kgroeneveld@gmail.com>
Date: Sun, 22 Jul 2012 16:19:56 -0400

> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
> rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
> The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
> SIOCGPPPSTATS ioctl is still 32 bit stats only.
> 
> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>

I don't see this as being very practical nor justified.
