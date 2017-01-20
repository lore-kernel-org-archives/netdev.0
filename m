From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: don't use sk_v6_rcv_saddr directly
Date: Fri, 20 Jan 2017 14:36:08 -0500 (EST)
Message-ID: <20170120.143608.2019214797201098379.davem@davemloft.net>
References: <1484866066-25407-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kafai@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbdATTgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:36:15 -0500
In-Reply-To: <1484866066-25407-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Thu, 19 Jan 2017 17:47:46 -0500

> When comparing two sockets we need to use inet6_rcv_saddr so we get a NULL
> sk_v6_rcv_saddr if the socket isn't AF_INET6, otherwise our comparison function
> can be wrong.
> 
> Fixes: 637bc8b ("inet: reset tb->fastreuseport when adding a reuseport sk")
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Applied, thanks.
