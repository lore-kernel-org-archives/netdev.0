From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: copy lwtstate in ip6_rt_copy_init()
Date: Mon, 27 Jul 2015 01:03:02 -0700 (PDT)
Message-ID: <20150727.010302.1024857271403625179.davem@davemloft.net>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbbG0IDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:03:02 -0400
In-Reply-To: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 24 Jul 2015 12:28:35 +0200

> We need to copy this field (ip6_rt_cache_alloc() and ip6_rt_pcpu_alloc()
> use ip6_rt_copy_init() to build a dst).
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
