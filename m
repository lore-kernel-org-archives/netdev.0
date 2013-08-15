From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4,ipv6: send arp/ndisc packets with TC_PRIO_CONTROL
Date: Thu, 15 Aug 2013 05:56:49 +0200
Message-ID: <20130815035649.GG13066@order.stressinduktion.org>
References: <20130814233412.GC13066@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dave.taht@gmail.com
To: netdev@vger.kernel.org, bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52752 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758636Ab3HOD4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 23:56:53 -0400
Content-Disposition: inline
In-Reply-To: <20130814233412.GC13066@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 01:34:12AM +0200, Hannes Frederic Sowa wrote:
> We already did this change for igmp/mld packets in commit
> 9d4a0314642918cbda9ed4012df51e8df608fce6 ("ipv4, ipv6: send igmpv3/mld
> packets with TC_PRIO_CONTROL").
> 
> arp and ndisc are as important as mld/igmp for a working network, so
> make the appropriate change here, too.
> 
> Cc: Benjamin LaHaise <bcrl@kvack.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I would like to downgrade this patch from tag net-next to RFC.

After Dave Taht talked to me, I realized that this change could have drastic
impact on how packets could starve in various qdiscs if a router is last hop
for a ping scan.

Please postpone this patch until I did more research. Comments are welcome,
too.

Thanks,

  Hannes
