From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: add skb_memcpy_to[from]_msg() to
 optimize skb code
Date: Wed, 18 Oct 2017 12:18:34 +0100 (WEST)
Message-ID: <20171018.121834.1670470800745081134.davem@davemloft.net>
References: <1508155873-23752-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752819AbdJRLSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:18:41 -0400
In-Reply-To: <1508155873-23752-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Mon, 16 Oct 2017 20:11:13 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> add these two wrappers in skbuff.h which is better named
> than previous and only used for skb.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Doing the skb_put() inside of the helper function makes code less
intuitive.

If someone is auditing code it's easier to see the skb_put() and
understand what is happening when it's at the call site rather than
buried in some helper.

Sorry, I don't see these changes as an improvement and will not apply
them.

Thank you.
