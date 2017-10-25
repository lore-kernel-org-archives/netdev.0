From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/4] net: remove rtmsg_ifinfo used in bridge
 and bonding
Date: Wed, 25 Oct 2017 10:55:09 +0900 (KST)
Message-ID: <20171025.105509.1345511040550558669.davem@davemloft.net>
References: <cover.1508824093.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com, jiri@resnulli.us
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdJYBzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:55:13 -0400
In-Reply-To: <cover.1508824093.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 24 Oct 2017 13:54:16 +0800

> It's better to send notifications to userspace by the events in
> rtnetlink_event, instead of calling rtmsg_ifinfo directly.
> 
> This patcheset is to remove rtmsg_ifinfo called in bonding and
> bridge, the notifications can be handled by NETDEV_CHANGEUPPER
> and NETDEV_CHANGELOWERSTATE events in rtnetlink_event.
> 
> It could also fix some redundant notifications from bonding and
> bridge.
> 
> v1->v2:
>   - post to net-next.git instead of net.git, for it's more like an
>     improvement for bonding
> v2->v3:
>   - add patch 1/4 to remove rtmsg_ifinfo called in add_del_if

Series applied, thanks.
