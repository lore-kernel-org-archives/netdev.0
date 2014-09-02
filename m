From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: add slave_changelink support and use
 it for queue_id
Date: Mon, 01 Sep 2014 18:32:51 -0700 (PDT)
Message-ID: <20140901.183251.398827984655633411.davem@davemloft.net>
References: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
	<5400638C.2030502@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaIBBcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:32:53 -0400
In-Reply-To: <5400638C.2030502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri, 29 Aug 2014 13:27:08 +0200

> On 08/27/2014 04:06 PM, Nikolay Aleksandrov wrote:
>> This patch adds support for slave_changelink to the bonding and uses it
>> to give the ability to change the queue_id of the enslaved devices via
>> netlink. It sets slave_maxtype and uses bond_changelink as a prototype for
>> bond_slave_changelink.
>> Example/test command after the iproute2 patch:
>>  ip link set eth0 type bond_slave queue_id 10
>> 
>> CC: David S. Miller <davem@davemloft.net>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> 
>> Suggested-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
> 
> Hi Dave,
> Would you mind telling me why did this patch get rejected so I can fix it up ?
> I didn't see any complains and Jiri acked it.

Sorry, I misread the feedback, this patch is fine, and is now applied.
