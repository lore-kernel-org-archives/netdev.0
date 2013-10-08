From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net ipv4: Allow unprivileged users to use most of the
 per net systctls
Date: Tue, 08 Oct 2013 00:45:09 -0400 (EDT)
Message-ID: <20131008.004509.2088608232981571154.davem@davemloft.net>
References: <878uy4skek.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab3JHEpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 00:45:13 -0400
In-Reply-To: <878uy4skek.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 07 Oct 2013 16:58:43 -0700

> 
> Allow unprivileged users to use:
> /proc/sys/net/ipv4/icmp_echo_ignore_all
> /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
> /proc/sys/net/ipv4/icmp_ignore_bogus_error_response
> /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
> /proc/sys/net/ipv4/icmp_ratelimit
> /proc/sys/net/ipv4/icmp_ratemask
> /proc/sys/net/ipv4/ping_group_range
> /proc/sys/net/ipv4/tcp_ecn
> /proc/sys/net/ipv4/ip_local_ports_range
 ...
> -			table[0].procname = NULL;
> +			table[9].procname = NULL;

Regardless of what I think semantically of this change, you really
have to find some way to avoid this magic constant.

Thanks.
