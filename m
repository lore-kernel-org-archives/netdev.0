From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] rtnetlink: Cleanup user notifications
 for netdev events
Date: Thu, 13 Apr 2017 13:17:02 -0400 (EDT)
Message-ID: <20170413.131702.2026236531356763784.davem@davemloft.net>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753970AbdDMRRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 13:17:10 -0400
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 11 Apr 2017 17:02:39 -0700

> Vlad's recent patch to add the event type to rtnetlink notifications
> points out a number of redundant or unnecessary notifications sent to
> userspace for events that are essentially internal to the kernel. Trim
> the list to put a dent in the notification storm.
> 
> v2
> - rebased to top of net-next with IFLA_EVENT patch reverted
> - dropped removal NETDEV_CHANGEINFODATA since it is intentionally
>   only to send a message to userspace
> - dropped NOTIFY_PEERS since Vlad's says it is needed for macvlans
> - add patches to remove NETDEV_CHANGEUPPER and NETDEV_CHANGE_TX_QUEUE_LEN
>   from the event list

Series applied, thanks David.
