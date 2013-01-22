From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Tue, 22 Jan 2013 16:25:08 -0500 (EST)
Message-ID: <20130122.162508.472486284426521608.davem@davemloft.net>
References: <1358889636-1651-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204Ab3AVVZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:25:10 -0500
In-Reply-To: <1358889636-1651-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 22 Jan 2013 13:20:36 -0800

> -			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
> +			*(__sum16 *)ptr = csum_fold(skb_checksum(skb,
> +						skb_transport_offset(skb),
> +						skb->len - skb_transport_offset(skb),
> +						0));

This is not the correct way to indent a multi-line function call.

The second and subsequent lines should be indented by a combination of
TAB and space characters, as needed, to make the first non-space
character line up with the first column after the openning parenthesis
of the first line.
