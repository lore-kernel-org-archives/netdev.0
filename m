From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Thu, 10 Apr 2014 23:30:20 -0400 (EDT)
Message-ID: <20140410.233020.1295376284838706264.davem@davemloft.net>
References: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<534753D4.6070600@linux-ipv6.org>
	<1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	f.wellenreiter@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754654AbaDKDaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 23:30:22 -0400
In-Reply-To: <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Apr 2014 20:20:27 -0700

> +/* We do not (yet ?) support IPv6 jumbograms (RFC 2675)
> + * Unlike IPv4, hdr->seg_len doesn't include the IPv6 header
> + */
> +#define IP6_MAX_MTU (0xFFFF + sizeof(struct ipv6hdr))

Hmmm, does this still match $Subj?
