From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Add a tcp_filter hook before handle ack packet
Date: Thu, 22 Jun 2017 11:13:52 -0400 (EDT)
Message-ID: <20170622.111352.1727281113882870166.davem@davemloft.net>
References: <1498010800-3918-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdFVPOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:14:04 -0400
In-Reply-To: <1498010800-3918-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Tue, 20 Jun 2017 19:06:40 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> Currently in both ipv4 and ipv6 code path, the ack packet received when
> sk at TCP_NEW_SYN_RECV state is not filtered by socket filter or cgroup
> filter since it is handled from tcp_child_process and never reaches the
> tcp_filter inside tcp_v4_rcv or tcp_v6_rcv. Adding a tcp_filter hooks
> here can make sure all the ingress tcp packet can be correctly filtered.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied, thanks.
