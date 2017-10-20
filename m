From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: Change fib notifiers to take a
 fib_alias
Date: Fri, 20 Oct 2017 13:29:52 +0100 (WEST)
Message-ID: <20171020.132952.1380333350387297807.davem@davemloft.net>
References: <1508351953-26442-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbdJTM34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 08:29:56 -0400
In-Reply-To: <1508351953-26442-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 18 Oct 2017 11:39:13 -0700

> All of the notifier data (fib_info, tos, type and table id) are
> contained in the fib_alias. Pass it to the notifier instead of
> each data separately shortening the argument list by 3.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
