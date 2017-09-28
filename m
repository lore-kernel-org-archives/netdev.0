From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_weight
Date: Wed, 27 Sep 2017 21:51:01 -0700 (PDT)
Message-ID: <20170927.215101.2052729160923454927.davem@davemloft.net>
References: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdI1EvC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:51:02 -0400
In-Reply-To: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 27 Sep 2017 19:08:00 -0700

> fib_weight in fib_info is set but not used. Remove it and the
> helpers for setting it.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Hmmm, I wonder then what Peter intended in commit
0e884c78ee19e902f300ed147083c28a0c6302f0 ("ipv4: L3 hash-based
multipath") because that's where this came from.
