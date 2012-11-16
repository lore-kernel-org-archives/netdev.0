From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Make IPv6 build depend on CONFIG_INET
Date: Thu, 15 Nov 2012 22:49:02 -0500 (EST)
Message-ID: <20121115.224902.18384275097690297.davem@davemloft.net>
References: <50a57815.U2EL8TTOk3ffGeV3%fengguang.wu@intel.com>
	<1353033297-2724-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab2KPDtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 22:49:08 -0500
In-Reply-To: <1353033297-2724-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 15 Nov 2012 21:34:57 -0500

> IPv6 build selection currently controlled by CONFIG_NET, so it is
> possible to build IPv6 functinality without selectiona any TCP/IP
> features (CONFIG_INET).  Make IPv6 be consistent with IPv4.
> 
> This should resolve the following issue:
> 
> net/built-in.o: In function `tcp6_gro_complete':
> tcpv6_offload.c:(.text+0x3d045): undefined reference to
> `tcp_gro_complete'
> net/built-in.o: In function `tcp6_gro_receive':
> tcpv6_offload.c:(.text+0x3d19b): undefined reference to
> `tcp_gro_receive'
> net/built-in.o: In function `ipv6_exthdrs_offload_init':
> (.init.text+0x118b): undefined reference to `inet_del_offload'
> net/built-in.o:(.rodata+0x1c58): undefined reference to
> `tcp_tso_segment'
> 
> Signed-off-by: Vlad Yasevich <vyasvic@redhat.com>

Applied.
