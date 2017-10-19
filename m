From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bonding: void calling rtmsg_ifinfo for netlink
 notifications
Date: Thu, 19 Oct 2017 13:03:34 +0100 (WEST)
Message-ID: <20171019.130334.2228539320348345811.davem@davemloft.net>
References: <cover.1508233044.git.lucien.xin@gmail.com>
        <20171017095943.GE2112@nanopsycho>
        <CADvbK_c7R2OJNq=DyXOCSNVzD2aU2qxBO6UiitGbCYS=icwxTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753213AbdJSMDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:03:44 -0400
In-Reply-To: <CADvbK_c7R2OJNq=DyXOCSNVzD2aU2qxBO6UiitGbCYS=icwxTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 17 Oct 2017 18:28:45 +0800

> On Tue, Oct 17, 2017 at 5:59 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Oct 17, 2017 at 11:39:38AM CEST, lucien.xin@gmail.com wrote:
>>>It's better to send notifications to userspace by the events
>>>in rtnetlink_event, instead of calling rtmsg_ifinfo directly.
>>>
>>>This patcheset is to remove rtmsg_ifinfo called in bonding,
>>>the notifications can be handled by NETDEV_CHANGEUPPER and
>>>NETDEV_CHANGELOWERSTATE events in rtnetlink_event.
>>>
>>>It could also fix some redundant notifications from bonding.
>>
>> This should go to net-next.
> 
> NETDEV_CHANGEUPPER is not yet in rtnetlink_event in net-next tree.
> patches can only work on net tree by now.
> 
> Hi, David, you want me to hold them until the patches for NETDEV_CHANGEUPPER
> are copied to net-next, or you would apply them to net ?

Please hold until net is next merged into net-next, thank you.
