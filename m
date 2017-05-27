From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next 0/2] rtnetlink: Updates to
 rtnetlink_event()
Date: Sat, 27 May 2017 18:52:10 -0400 (EDT)
Message-ID: <20170527.185210.1614681423458551500.davem@davemloft.net>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdE0WwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:52:19 -0400
In-Reply-To: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Sat, 27 May 2017 10:14:33 -0400

> First is the patch to add IFLA_EVENT attribute to the netlink message.  It
> supports only currently white-listed events.
> Like before, this is just an attribute that gets added to the rtnetlink
> message only when the messaged was generated as a result of a netdev event.
> In my case, this is necessary since I want to trap NETDEV_NOTIFY_PEERS
> event (also possibly NETDEV_RESEND_IGMP event) and perform certain actions
> in user space.  This is not possible since the messages generated as
> a result of netdev events do not usually contain any changed data.  They
> are just notifications.  This patch exposes this notification type to
> userspace.
> 
> Second, I remove duplicate messages that a result of a change to bonding
> options.  If netlink is used to configure bonding options, 2 messages
> are generated, one as a result NETDEV_CHANGEINFODATA event triggered by
> bonding code and one a result of device state changes triggered by
> netdev_state_change (called from do_setlink).
 ...

Series applied, thanks Vlad.
