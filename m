From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: unify dst caching for tunnel
 devices
Date: Tue, 16 Feb 2016 20:22:21 -0500 (EST)
Message-ID: <20160216.202221.489011866131335381.davem@davemloft.net>
References: <cover.1455287867.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, pshelar@nicira.com,
	jbenc@redhat.com, hannes@stressinduktion.org, therbert@google.com,
	sergei.shtylyov@cogentembedded.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275AbcBQBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:22:24 -0500
In-Reply-To: <cover.1455287867.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 12 Feb 2016 15:43:52 +0100

> This patch series try to unify the dst cache implementations currently
> present in the kernel, namely in ip_tunnel.c and ip6_tunnel.c, introducing a
> new generic implementation, replacing the existing ones, and then using
> the new implementation in other tunnel devices which currently lack it.
> 
> The new dst implementation is compiled, as built-in, only if any device using
> it is enabled.
> 
> Caching the dst for the tunnel remote address gives small, but measurable,
> performance improvement when tunneling over ipv4 (in the 2%-4% range) and
> significant ones when tunneling over ipv6 (roughly 60% when no
> fragmentation/segmentation take place and the tunnel local address
> is not specified).
> 
> v2:
> - move the vxlan dst_cache usage inside the device lookup functions
> - fix usage after free for lwt tunnel moving the dst cache storage inside
>   the dst_metadata,
> - sparse codying style cleanup

Series applied, thanks for doing this work as it is a major improvement.
