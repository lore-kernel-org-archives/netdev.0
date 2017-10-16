From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] rtnetlink: a bunch of fixes for userspace
 notifications in changing dev properties
Date: Mon, 16 Oct 2017 20:49:54 +0100 (WEST)
Message-ID: <20171016.204954.567930121040592246.davem@davemloft.net>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755487AbdJPTt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 15:49:56 -0400
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 15 Oct 2017 18:13:40 +0800

> Whenever any property of a link, address, route, etc. changes by whatever way,
> kernel should notify the programs that listen for such events in userspace.
> 
> The patchet "rtnetlink: Cleanup user notifications for netdev events" tried to
> fix a redundant notifications issue, but it also introduced a side effect.
> 
> After that, user notifications could only be sent when changing dev properties
> via netlink api. As it removed some events process in rtnetlink_event where
> the notifications was sent to users.
> 
> It resulted in no notification generated when dev properties are changed via
> other ways, like ioctl, sysfs, etc. It may cause some user programs doesn't
> work as expected because of the missing notifications.
> 
> This patchset will fix it by bringing some of these netdev events back and
> also fix the old redundant notifications issue with a proper way.

Series applied, thank you.
