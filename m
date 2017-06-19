From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: raw: assign delivered after receive
 success
Date: Mon, 19 Jun 2017 10:55:36 -0400 (EDT)
Message-ID: <20170619.105536.1276405885251457364.davem@davemloft.net>
References: <1497875858-22402-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdFSOzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 10:55:38 -0400
In-Reply-To: <1497875858-22402-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Mon, 19 Jun 2017 20:37:38 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> it's not reasonable to assign delivered if packet match no RAW sock
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

'delivered' means there was a matching raw socket.

It doesn't say anything about what the socket decided to do with
the packet.

I'm not applying this, sorry.
