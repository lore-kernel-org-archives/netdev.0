From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PATCH net-next] bonding: make release_and_destroy static
Date: Fri, 15 Oct 2010 16:16:33 -0700
Message-ID: <24308.1287184593@death>
References: <20101015080934.6dc28388@nehalam> <20101015153725.GC7497@gospo.rdu.redhat.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45723 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab0JOXQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 19:16:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9FN6u3I002713
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:06:56 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9FNGZVY127120
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:16:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9FNGYKP023118
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:16:35 -0600
In-reply-to: <20101015153725.GC7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Fri, Oct 15, 2010 at 08:09:34AM -0700, Stephen Hemminger wrote:
>> Only used in main file.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> --- a/drivers/net/bonding/bond_main.c	2010-10-15 08:07:14.163898236 -0700
>> +++ b/drivers/net/bonding/bond_main.c	2010-10-15 08:07:31.956373660 -0700
>> @@ -2057,8 +2057,8 @@ int bond_release(struct net_device *bond
>>  * First release a slave and than destroy the bond if no more slaves are left.
>>  * Must be under rtnl_lock when this function is called.
>>  */
>> -int  bond_release_and_destroy(struct net_device *bond_dev,
>> -			      struct net_device *slave_dev)
>> +static int  bond_release_and_destroy(struct net_device *bond_dev,
>> +				     struct net_device *slave_dev)
>>  {
>>  	struct bonding *bond = netdev_priv(bond_dev);
>>  	int ret;
>> --- a/drivers/net/bonding/bonding.h	2010-10-15 08:07:14.179898632 -0700
>> +++ b/drivers/net/bonding/bonding.h	2010-10-15 08:07:31.956373660 -0700
>> @@ -334,7 +334,6 @@ static inline void bond_unset_master_alb
>>  struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
>>  int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
>>  int bond_create(struct net *net, const char *name);
>> -int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
>>  int bond_create_sysfs(void);
>>  void bond_destroy_sysfs(void);
>>  void bond_prepare_sysfs_group(struct bonding *bond);
>
>Seems fine.
>
>Acked-by: Andy Gospodarek <andy@greyhouse.net>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
