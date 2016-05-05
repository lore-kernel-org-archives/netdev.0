From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] macvtap: add namespace support to the
 sysfs device class
Date: Wed, 04 May 2016 23:53:08 -0400 (EDT)
Message-ID: <20160504.235308.1088954708869507214.davem@davemloft.net>
References: <1462300254-22273-1-git-send-email-marc@arista.com>
	<20160504.160445.640444073175153113.davem@davemloft.net>
	<CAPSAET_zPYBvMdTQ5m1O9xO178Jk0b93rC1cy0CNY2yinUbnXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: marc@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661AbcEEDxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:53:12 -0400
In-Reply-To: <CAPSAET_zPYBvMdTQ5m1O9xO178Jk0b93rC1cy0CNY2yinUbnXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Angel <marc@arista.com>
Date: Thu, 5 May 2016 01:33:09 +0100

> On Wed, May 4, 2016 at 9:04 PM, David Miller <davem@davemloft.net> wrote:
>> From: Marc Angel <marc@arista.com>
>> Date: Tue,  3 May 2016 20:30:54 +0200
>>
>>> @@ -1274,6 +1285,7 @@ static int macvtap_device_event(struct notifier_block *unused,
>>>                               unsigned long event, void *ptr)
>>>  {
>>>       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>>> +     const char *tap_name = kasprintf(GFP_KERNEL, "tap%d", dev->ifindex);
>>>       struct macvlan_dev *vlan;
>>>       struct device *classdev;
>>>       dev_t devt;
>>
>> This 'tap_name' buffer seems to be leaked in several code paths.
> 
> Sorry about that... V3 should be better.

V3 doesn't apply cleanly to net-next, please respin your patch against
the current tree.

Thanks.
