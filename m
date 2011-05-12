From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic
 constants.
Date: Thu, 12 May 2011 18:28:57 -0400 (EDT)
Message-ID: <20110512.182857.1123203303677885686.davem@davemloft.net>
References: <alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg>
	<20110510.153051.71135029.davem@davemloft.net>
	<alpine.LFD.2.00.1105120212150.2431@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757335Ab1ELW3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:29:13 -0400
In-Reply-To: <alpine.LFD.2.00.1105120212150.2431@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 12 May 2011 02:32:09 +0300 (EEST)

> 	My simple tests do not show any problems with patches
> 4, 5 and the new 6 and 7. I tested TUN mode for rt_src/rt_dst
> and DR/NAT for rt_dst replacement, related ICMP is relayed properly.
> So, we should be ok but I'll do more tests in the following
> days because the list with possible combinations for testing
> is too long: different forwarding mode (DR/TUN/NAT),
> local or remote real server, local or remote client,
> In or Out related ICMP, Passive or Active FTP...

Julian, I integrated your work and pushed 3 patches to net-next-2.6

1) Original patch #4 with your followup integrated
2) Original patch #5
3) You're replacement for original patch #6 and #7

Let me know if there are any followup fixes that we need to work
on.

Thanks!
