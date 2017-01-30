From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] openvswitch: Simplify do_execute_actions().
Date: Sun, 29 Jan 2017 19:00:51 -0500 (EST)
Message-ID: <20170129.190051.1544744982724865560.davem@davemloft.net>
References: <1485553528-16248-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdA3ABV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 19:01:21 -0500
In-Reply-To: <1485553528-16248-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@ovn.org>
Date: Fri, 27 Jan 2017 13:45:28 -0800

> do_execute_actions() implements a worthwhile optimization: in case
> an output action is the last action in an action list, skb_clone()
> can be avoided by outputing the current skb. However, the
> implementation is more complicated than necessary.  This patch
> simplify this logic.
> 
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
> v1->v2:  drop skb NULL check in do_output()

Applied, thank you.
