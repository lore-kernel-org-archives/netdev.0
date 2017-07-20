From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] rtnetlink: allocate more memory for
 dev_set_mac_address()
Date: Thu, 20 Jul 2017 15:23:51 -0700 (PDT)
Message-ID: <20170720.152351.756381405791784095.davem@davemloft.net>
References: <20170720182758.20204-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965429AbdGTWXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:23:52 -0400
In-Reply-To: <20170720182758.20204-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 20 Jul 2017 11:27:57 -0700

> virtnet_set_mac_address() interprets mac address as struct
> sockaddr, but upper layer only allocates dev->addr_len
> which is ETH_ALEN + sizeof(sa_family_t) in this case.
> 
> We lack a unified definition for mac address, so just fix
> the upper layer, this also allows drivers to interpret it
> to struct sockaddr freely.
> 
> Reported-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks Cong.
