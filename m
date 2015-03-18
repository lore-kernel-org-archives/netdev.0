From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 3/4] IB/mlx4: Saturate RoCE port PMA counters in case
 of overflow
Date: Wed, 18 Mar 2015 16:44:26 +0200
Message-ID: <55098F4A.3010309@mellanox.com>
References: <1426688693-18980-1-git-send-email-ogerlitz@mellanox.com>
 <1426688693-18980-4-git-send-email-ogerlitz@mellanox.com>
 <55098D6F.7040008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0075.outbound.protection.outlook.com ([157.55.234.75]:52078
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755024AbbCROoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:44:32 -0400
In-Reply-To: <55098D6F.7040008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/18/2015 4:36 PM, Sergei Shtylyov wrote:
>> diff --git a/drivers/infiniband/hw/mlx4/mad.c 
>> b/drivers/infiniband/hw/mlx4/mad.c
>> index c761971..40850f1 100644
>> --- a/drivers/infiniband/hw/mlx4/mad.c
>> +++ b/drivers/infiniband/hw/mlx4/mad.c
>> @@ -64,6 +64,17 @@ enum {
>>   #define GUID_TBL_BLK_NUM_ENTRIES 8
>>   #define GUID_TBL_BLK_SIZE (GUID_TBL_ENTRY_SIZE * 
>> GUID_TBL_BLK_NUM_ENTRIES)
>>
>> +#define MAX_BE32 0xffffffffULL
>> +#define MAX_BE16 0xffffUL
>
>    Aren't U{16|32}_MAX from <linux/kernel.h> good enough?
>    And I'm not seeing wheer MAX_BE16 is used...
>
> [...] 

sure, I will roll now quick fix for both issues...thanks
