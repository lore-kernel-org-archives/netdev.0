From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: send NEWLINK on RA managed/otherconf changes
Date: Mon, 31 Aug 2015 15:13:51 -0700 (PDT)
Message-ID: <20150831.151351.228280334434841531.davem@davemloft.net>
References: <20150831135922.GA24179@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mt@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbbHaWNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 18:13:54 -0400
In-Reply-To: <20150831135922.GA24179@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marius Tomaschewski <mt@suse.de>
Date: Mon, 31 Aug 2015 15:59:22 +0200

> The kernel is applying the RA managed/otherconf flags silently and
> forgets to send ifinfo notify to inform about their change when the
> router provides a zero reachable_time and retrans_timer as dnsmasq
> and many routers send it, which just means unspecified by this router
> and the host should continue using whatever value it is already using.
> Userspace may monitor the ifinfo notifications to activate dhcpv6.
> 
> Signed-off-by: Marius Tomaschewski <mt@suse.de>

Applied, but more ideally this function should emit only a single
NEWLINK message rather than potentially 3.
