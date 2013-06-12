From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: ipv6: numa: consolidate skb
 allocation to pktgen_alloc_skb
Date: Wed, 12 Jun 2013 00:48:53 -0700 (PDT)
Message-ID: <20130612.004853.513619603946162801.davem@davemloft.net>
References: <1370693896-9294-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab3FLHsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:48:54 -0400
In-Reply-To: <1370693896-9294-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  8 Jun 2013 14:18:16 +0200

> We currently allow for numa-node aware skb allocation only within the
> fill_packet_ipv4() path, but not in fill_packet_ipv6(). Consolidate that
> code to a common allocation helper to enable numa-node aware skb
> allocation for ipv6, and use it in both paths. This also makes both
> functions a bit more readable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
