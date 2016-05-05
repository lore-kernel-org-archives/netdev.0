From: Marc Angel <marc@arista.com>
Subject: Re: [PATCH net-next v2] macvtap: add namespace support to the sysfs
 device class
Date: Thu, 5 May 2016 01:33:09 +0100
Message-ID: <CAPSAET_zPYBvMdTQ5m1O9xO178Jk0b93rC1cy0CNY2yinUbnXw@mail.gmail.com>
References: <CAPSAET_u3CYvhYgyxXdomi7n5Z6c1DTCpSMv=K544U=TjmM=cw@mail.gmail.com>
 <1462300254-22273-1-git-send-email-marc@arista.com> <20160504.160445.640444073175153113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33418 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822AbcEEAda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 20:33:30 -0400
Received: by mail-ob0-f173.google.com with SMTP id x1so29291063obt.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 17:33:29 -0700 (PDT)
In-Reply-To: <20160504.160445.640444073175153113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 9:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Marc Angel <marc@arista.com>
> Date: Tue,  3 May 2016 20:30:54 +0200
>
>> @@ -1274,6 +1285,7 @@ static int macvtap_device_event(struct notifier_block *unused,
>>                               unsigned long event, void *ptr)
>>  {
>>       struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>> +     const char *tap_name = kasprintf(GFP_KERNEL, "tap%d", dev->ifindex);
>>       struct macvlan_dev *vlan;
>>       struct device *classdev;
>>       dev_t devt;
>
> This 'tap_name' buffer seems to be leaked in several code paths.

Sorry about that... V3 should be better.
