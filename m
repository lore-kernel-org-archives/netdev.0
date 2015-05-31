From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: limit tcp/udp rmem/wmem to
 SOCK_{RCV,SND}BUF_MIN
Date: Sat, 30 May 2015 17:38:01 -0700 (PDT)
Message-ID: <20150530.173801.2153347937714837735.davem@davemloft.net>
References: <1432754209-21397-1-git-send-email-sorin@returnze.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sorin@returnze.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422AbbEaAiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 20:38:04 -0400
In-Reply-To: <1432754209-21397-1-git-send-email-sorin@returnze.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sorin Dumitru <sorin@returnze.ro>
Date: Wed, 27 May 2015 22:16:49 +0300

> This is similar to b1cb59cf2efe(net: sysctl_net_core: check SNDBUF
> and RCVBUF for min length). I don't think too small values can cause
> crashes in the case of udp and tcp, but I've seen this set to too
> small values which triggered awful performance. It also makes the
> setting consistent across all the wmem/rmem sysctls.
> 
> Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>

Applied, thank you.
