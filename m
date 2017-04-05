From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] rtnetlink: Updates to rtnetlink_event()
Date: Wed, 05 Apr 2017 08:14:45 -0700 (PDT)
Message-ID: <20170405.081445.313179619035222328.davem@davemloft.net>
References: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752408AbdDEPOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 11:14:51 -0400
In-Reply-To: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue,  4 Apr 2017 09:23:40 -0400

> This series came out of the conversation that started as a result
> my first attempt to add netdevice event info to netlink messages.
> 
> This series converts event processing to a 'white list', where
> we explicitely permit events to generate netlink messages.  This
> is meant to make people take a closer look and determine wheter
> these events should really trigger netlink messages.
> 
> I am also adding a V2 of my patch to add event type to the netlink
> message.  This version supports all events that we currently generate.
> 
> I will also update my patch to iproute that will show this data
> through 'ip monitor'. 
> 
> I actually need the ability to trap NETDEV_NOTIFY_PEERS event
> (as well as possible NETDEV_RESEND_IGMP) to support hanlding of
> macvtap on top of bonding.  I hope others will also find this info usefull.
> 
> V2: Added missed events (from David Ahern)

Series applied, thanks Vlad.
