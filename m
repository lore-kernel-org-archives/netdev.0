From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: add gro capability
Date: Mon, 03 Aug 2015 14:23:08 -0700 (PDT)
Message-ID: <20150803.142308.1032997735864227733.davem@davemloft.net>
References: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbbHCVXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:23:09 -0400
In-Reply-To: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 Jul 2015 18:25:17 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Straightforward patch to add GRO processing to virtio_net.
> 
> napi_complete_done() usage allows more aggressive aggregation,
> opted-in by setting /sys/class/net/xxx/gro_flush_timeout
> 
> Tested:
> 
> Setting /sys/class/net/xxx/gro_flush_timeout to 1000 nsec,
> Rick Jones reported following results.
> 
> One VM of each on a pair of OpenStack compute nodes with E5-2650Lv3 CPUs
> and Intel 82599ES-based NICs. So, two "before" and two "after" VMs.
> The OpenStack compute nodes were running OpenStack Kilo, with VxLAN
> encapsulation being used through OVS so no GRO coming-up the host
> stack.  The compute nodes themselves were running a 3.14-based kernel.
> 
> Single-stream netperf, CPU utilizations and thus service demands are
> based on intra-guest reported CPU.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Rick Jones <rick.jones2@hp.com>

Applied.
