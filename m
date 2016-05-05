From: Marc Angel <marc@arista.com>
Subject: Re: [PATCH net-next v2] macvtap: add namespace support to the sysfs
 device class
Date: Thu, 5 May 2016 11:12:34 +0100
Message-ID: <CAPSAET_U+zMqtDDCPJG3Bp8kcS_VTf3eCQ_1v88jG0tPjVgYBQ@mail.gmail.com>
References: <1462300254-22273-1-git-send-email-marc@arista.com>
 <20160504.160445.640444073175153113.davem@davemloft.net> <CAPSAET_zPYBvMdTQ5m1O9xO178Jk0b93rC1cy0CNY2yinUbnXw@mail.gmail.com>
 <20160504.235308.1088954708869507214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35602 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283AbcEEKMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 06:12:55 -0400
Received: by mail-oi0-f52.google.com with SMTP id x19so96971937oix.2
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 03:12:55 -0700 (PDT)
In-Reply-To: <20160504.235308.1088954708869507214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2016 at 4:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Marc Angel <marc@arista.com>
> Date: Thu, 5 May 2016 01:33:09 +0100
>
>> On Wed, May 4, 2016 at 9:04 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Marc Angel <marc@arista.com>
>>> Date: Tue,  3 May 2016 20:30:54 +0200
>>>
>>>> @@ -1274,6 +1285,7 @@ static int macvtap_device_event(struct notifier_block *unused,
>>>>                               unsigned long event, void *ptr)
>>>>  {
>>>>       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>>>> +     const char *tap_name = kasprintf(GFP_KERNEL, "tap%d", dev->ifindex);
>>>>       struct macvlan_dev *vlan;
>>>>       struct device *classdev;
>>>>       dev_t devt;
>>>
>>> This 'tap_name' buffer seems to be leaked in several code paths.
>>
>> Sorry about that... V3 should be better.
>
> V3 doesn't apply cleanly to net-next, please respin your patch against
> the current tree.
>
> Thanks.

I wasn't up-to-date, sorry again about that...

Thanks for being so patient.
