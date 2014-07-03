From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vlan: free percpu stats in device destructor
Date: Wed, 02 Jul 2014 17:02:35 -0700 (PDT)
Message-ID: <20140702.170235.955058899063669298.davem@davemloft.net>
References: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
	<1404293115.23797.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@freescale.com, roy.qing.li@gmail.com,
	edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaGCACj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 20:02:39 -0400
In-Reply-To: <1404293115.23797.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Jul 2014 02:25:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Madalin-Cristian reported crashs happening after a recent commit
> (5a4ae5f6e7d4 "vlan: unnecessary to check if vlan_pcpu_stats is NULL")
 ...
> Fix this problem by freeing percpu stats from dev->destructor() instead
> of ndo_uninit()
> 
> Reported-by: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
> Fixes: 5a4ae5f6e7d4 ("vlan: unnecessary to check if vlan_pcpu_stats is NULL")

Applied and queued up for -stable, thanks Eric.
