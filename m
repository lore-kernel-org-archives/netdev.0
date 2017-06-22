From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: ipv6: reset daddr and dport in sk if
 connect() fails
Date: Thu, 22 Jun 2017 13:25:00 -0400 (EDT)
Message-ID: <20170622.132500.2137901400094983652.davem@davemloft.net>
References: <20170621213631.145600-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, subashab@codeaurora.org, maze@google.com,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752370AbdFVRZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 13:25:02 -0400
In-Reply-To: <20170621213631.145600-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Wed, 21 Jun 2017 14:36:31 -0700

> +		memset(&sk->sk_v6_daddr, 0 sizeof(sk->sk_v6_daddr);

Tell me how that compiles.
