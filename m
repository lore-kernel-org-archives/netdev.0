From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 2/3] net_sched: fix some checkpatch errors
Date: Thu, 7 Nov 2013 09:33:19 +0800
Message-ID: <527AEDDF.2090102@huawei.com>
References: <1383725109-37348-1-git-send-email-yangyingliang@huawei.com> <1383725109-37348-3-git-send-email-yangyingliang@huawei.com> <20131106073741.154f8590@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26431 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787Ab3KGBdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:33:41 -0500
In-Reply-To: <20131106073741.154f8590@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/6 23:37, Stephen Hemminger wrote:
> On Wed, 6 Nov 2013 16:05:08 +0800
> Yang Yingliang <yangyingliang@huawei.com> wrote:
> 
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index fd70728..c8aadfa 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -191,7 +191,7 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
>>  			val = 1;
>>  	} while (tcf_hash_lookup(val, hinfo));
>>  
>> -	return (*idx_gen = val);
>> +	return *idx_gen = val;
> 
> That is not an improvement. I would rather see the return on a assingment and return
> on separate lines.
> 
> 
ok, i will fix it in v2.
