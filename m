From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use "unsigned int" in nla_next()
Date: Sat, 19 Nov 2016 22:11:54 -0500 (EST)
Message-ID: <20161119.221154.342519376993786527.davem@davemloft.net>
References: <20161119005435.GD1200@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753065AbcKTDLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:11:55 -0500
In-Reply-To: <20161119005435.GD1200@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 19 Nov 2016 03:54:35 +0300

> ->nla_len is unsigned entity (it's length after all) and u16,
> thus it can't overflow when being aligned into int/unsigned int.
> 
> (nlmsg_next has the same code, but I didn't yet convince myself
> it is correct to do so).
> 
> There is pointer arithmetic in this function and offset being
> unsigned is better:
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next.
