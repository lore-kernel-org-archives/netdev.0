From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: better control of DDOS
 traffic
Date: Wed, 04 Feb 2015 20:22:45 -0800 (PST)
Message-ID: <20150204.202245.1889006308590918014.davem@davemloft.net>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbbBEEWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:22:46 -0500
In-Reply-To: <1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Feb 2015 09:32:19 -0800

> +	if (tb[TCA_FQ_ORPHAN_MASK])
> +		q->orphan_mask = nla_get_u32(tb[TCA_FQ_ORPHAN_MASK]);

This doesn't build, the header file changes that add TCA_FQ_ORPHAN_MASK
are missing from your patch.
