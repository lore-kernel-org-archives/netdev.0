From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net ipv4: Convert ipv4.ip_local_port_range to
 be per netns
Date: Sat, 28 Sep 2013 15:52:28 -0400 (EDT)
Message-ID: <20130928.155228.211244914284752204.davem@davemloft.net>
References: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755080Ab3I1Twa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 15:52:30 -0400
In-Reply-To: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 22 Sep 2013 23:27:30 -0700

> 
> - Move sysctl_local_ports from a global variable into struct netns_ipv4.
> - Modify inet_get_local_port_range to take a struct net.
> - Manually expand inet_get_local_range into ipv4_local_port_range
>   because I do not know the struct net.
> - Move the initialization of sysctl_local_ports into
>   sysctl_net_ipv4.c:ipv4_sysctl_init_net from inet_connection_sock.c
> 
> Originally-by: Samya <samya@twitter.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
