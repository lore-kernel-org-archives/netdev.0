From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: snmp: fix 64bit stats on 32bit arches
Date: Thu, 28 Apr 2016 11:55:53 -0400 (EDT)
Message-ID: <20160428.115553.503130126299327138.davem@davemloft.net>
References: <1461844854.5535.93.camel@edumazet-glaptop3.roam.corp.google.com>
	<5721FFFC.9010808@6wind.com>
	<1461850404.5535.103.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, edumazet@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbcD1Pzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:55:55 -0400
In-Reply-To: <1461850404.5535.103.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Apr 2016 06:33:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I accidentally replaced BH disabling by preemption disabling
> in SNMP_ADD_STATS64() and SNMP_UPD_PO_STATS64() on 32bit builds.
> 
> For 64bit stats on 32bit arch, we really need to disable BH,
> since the "struct u64_stats_sync syncp" might be manipulated
> both from process and BH contexts.
> 
> Fixes: 6aef70a851ac ("net: snmp: kill various STATS_USER() helpers")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
