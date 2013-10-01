From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next ] net ipv4: Convert ipv4.ip_local_port_range
 to be per netns v3
Date: Mon, 30 Sep 2013 22:02:22 -0700 (PDT)
Message-ID: <20130930.220222.1005505656004866541.davem@davemloft.net>
References: <5240457D.2050101@6wind.com>
	<8738ovtea9.fsf_-_@tw-ebiederman.twitter.com>
	<87bo3c1wkc.fsf_-_@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAEzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:55:16 -0400
In-Reply-To: <87bo3c1wkc.fsf_-_@tw-ebiederman.twitter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 28 Sep 2013 14:10:59 -0700

> 
> - Move sysctl_local_ports from a global variable into struct netns_ipv4.
> - Modify inet_get_local_port_range to take a struct net, and update all
>   of the callers.
> - Move the initialization of sysctl_local_ports into
>    sysctl_net_ipv4.c:ipv4_sysctl_init_net from inet_connection_sock.c
> 
> v2:
> - Ensure indentation used tabs
> - Fixed ip.h so it applies cleanly to todays net-next
> 
> v3:
> - Compile fixes of strange callers of inet_get_local_port_range.
>   This patch now successfully passes an allmodconfig build.
>   Removed manual inlining of inet_get_local_port_range in ipv4_local_port_range
> 
> Originally-by: Samya <samya@twitter.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks Eric.
