From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bonding: deliver link-local packets with
 skb->dev set to link that packets arrived on
Date: Mon, 17 Apr 2017 15:46:09 -0400 (EDT)
Message-ID: <20170417.154609.1906784623460719468.davem@davemloft.net>
References: <20170416190218.57224-1-chonggangli@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
        maheshb@google.com, maze@google.com
To: chonggangli@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752398AbdDQTqL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:46:11 -0400
In-Reply-To: <20170416190218.57224-1-chonggangli@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chonggang Li <chonggangli@google.com>
Date: Sun, 16 Apr 2017 12:02:18 -0700

> Bonding driver changes the skb->dev to the bonding-master before
> passing the packet to stack for further processing. This, however
> does not make sense for the link-local packets and it looses "the
> link info" once its skb->dev is changed to bonding-master.  This
> patch changes this behavior for link-local packets by not changing
> the skb->dev to the bonding-master and maintaining it as it is,
> i.e. the link on which the packet arrived.
> 
> Signed-off-by: Chonggang Li <chonggangli@google.com>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>
> ---
> Changes in v2:
>   - Make the commit message more clearer.

Applied with "looses" type fixed.
