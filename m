From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: restore UDPlite many-cast delivery
Date: Tue, 15 Nov 2016 22:14:46 -0500 (EST)
Message-ID: <20161115.221446.2096636000015746095.davem@davemloft.net>
References: <1479163230-8734-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, drheld@google.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752445AbcKPDOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:14:48 -0500
In-Reply-To: <1479163230-8734-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 14 Nov 2016 23:40:30 +0100

> Honor udptable parameter that is passed to __udp*_lib_mcast_deliver(),
> otherwise udplite broadcast/multicast use the wrong table and it breaks.
> 
> Fixes: 2dc41cff7545 ("udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_deliver.")
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied and queued up for -stable, thanks Pablo.
