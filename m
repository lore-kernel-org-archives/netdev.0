From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ping_check_bind_addr() etc. can be
 static
Date: Thu, 13 Jun 2013 01:37:18 -0700 (PDT)
Message-ID: <20130613.013718.1550420867136382719.davem@davemloft.net>
References: <20130609122426.GA2715@localhost>
	<20130612130416.GA22783@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab3FMIhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:37:19 -0400
In-Reply-To: <20130612130416.GA22783@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>
Date: Wed, 12 Jun 2013 21:04:16 +0800

> net/ipv4/ping.c:286:5: sparse: symbol 'ping_check_bind_addr' was not declared. Should it be static?
> net/ipv4/ping.c:355:6: sparse: symbol 'ping_set_saddr' was not declared. Should it be static?
> net/ipv4/ping.c:370:6: sparse: symbol 'ping_clear_saddr' was not declared. Should it be static?
> 
> net/ipv6/ping.c:60:5: sparse: symbol 'dummy_ipv6_recv_error' was not declared. Should it be static?
> net/ipv6/ping.c:64:5: sparse: symbol 'dummy_ip6_datagram_recv_ctl' was not declared. Should it be static?
> net/ipv6/ping.c:69:5: sparse: symbol 'dummy_icmpv6_err_convert' was not declared. Should it be static?
> net/ipv6/ping.c:73:6: sparse: symbol 'dummy_ipv6_icmp_error' was not declared. Should it be static?
> net/ipv6/ping.c:75:5: sparse: symbol 'dummy_ipv6_chk_addr' was not declared. Should it be static?
> net/ipv6/ping.c:201:5: sparse: symbol 'ping_v6_seq_show' was not declared. Should it be static?
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Applied.
