From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove unnecessary check on
 orig_oif
Date: Sun, 13 Aug 2017 20:03:57 -0700 (PDT)
Message-ID: <20170813.200357.58123925823858404.davem@davemloft.net>
References: <1502496122-27784-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHNDD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 23:03:58 -0400
In-Reply-To: <1502496122-27784-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 11 Aug 2017 17:02:02 -0700

> rt_iif is going to be set to either 0 or orig_oif. If orig_oif
> is 0 it amounts to the same end result so remove the check.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David.
