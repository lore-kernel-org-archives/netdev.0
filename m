From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/4] netpoll: add IPv6 support
Date: Tue, 08 Jan 2013 17:56:27 -0800 (PST)
Message-ID: <20130108.175627.1534780496006559722.davem@davemloft.net>
References: <1357627962-28683-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912Ab3AIB42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:56:28 -0500
In-Reply-To: <1357627962-28683-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  8 Jan 2013 14:52:38 +0800

> v5: move some ipv6 checksum functions into net/ipv6/ip6_checksum.c
> 
> v4: remove ndisc_parse_options(), ignore ICMP options there
>     make udp6_csum_init() inline so that we don't rely on IPV6=y
>     fix a conflict with Jiri's patchset
> 
> v3: fix CONFIG_IPV6=m case
>  
> v2: use bool for ipv6 flag
>     fix !CONFIG_IPV6 case
> 
> This patchset implements netpoll over IPv6.

Series applied, thanks.
