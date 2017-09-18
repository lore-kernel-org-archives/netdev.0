From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udpv6: Fix the checksum computation when HW
 checksum does not apply
Date: Mon, 18 Sep 2017 11:43:44 -0700 (PDT)
Message-ID: <20170918.114344.588704137534470376.davem@davemloft.net>
References: <1505352651-14828-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdIRSnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 14:43:45 -0400
In-Reply-To: <1505352651-14828-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Wed, 13 Sep 2017 19:30:51 -0600

> While trying an ESP transport mode encryption for UDPv6 packets of
> datagram size 1436 with MTU 1500, checksum error was observed in
> the secondary fragment.
> 
> This error occurs due to the UDP payload checksum being missed out
> when computing the full checksum for these packets in
> udp6_hwcsum_outgoing().
> 
> Fixes: d39d938c8228 ("ipv6: Introduce udpv6_send_skb()")
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Good catch, applied and queued up for -stable.
