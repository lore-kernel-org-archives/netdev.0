From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vxlan: remove the dead codes
Date: Fri, 17 Oct 2014 16:24:49 -0400 (EDT)
Message-ID: <20141017.162449.747433271390481594.davem@davemloft.net>
References: <1413525844-2406-1-git-send-email-roy.qing.li@gmail.com>
	<CAHA+R7O7Yyd2XMkMnv5b_TLFekPCRRtOGG7bHgHs2Qd+YRu3Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbaJQUYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 16:24:51 -0400
In-Reply-To: <CAHA+R7O7Yyd2XMkMnv5b_TLFekPCRRtOGG7bHgHs2Qd+YRu3Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 17 Oct 2014 10:33:08 -0700

> On Thu, Oct 16, 2014 at 11:04 PM,  <roy.qing.li@gmail.com> wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> remove the dead codes, no user uses vxlan_salt
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  drivers/net/vxlan.c |    4 ----
>>  1 file changed, 4 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 77ab844..855a81d 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -152,8 +152,6 @@ struct vxlan_dev {
>>         struct hlist_head fdb_head[FDB_HASH_SIZE];
>>  };
>>
>> -/* salt for hash table */
>> -static u32 vxlan_salt __read_mostly;
> 
> Hmm, it has never been used since it was born. Maybe we should
> really use for vxlan hash table?

Yes, agreed, and I am very sure that this was Stephen Hemminger's
original intention.
