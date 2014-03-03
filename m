From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 10/12] vti6: Support inter address family tunneling.
Date: Sun, 02 Mar 2014 20:13:17 -0500 (EST)
Message-ID: <20140302.201317.1314804893361369873.davem@davemloft.net>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
	<1393583483-12480-11-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.gouault@6wind.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaCCBNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:13:18 -0500
In-Reply-To: <1393583483-12480-11-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Feb 2014 11:31:20 +0100

> +	if (net_xmit_eval(err) == 0) {
> +		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
> +		u64_stats_update_begin(&tstats->syncp);

Empty line between local variable declaration and code, please.
