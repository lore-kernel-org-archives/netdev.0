From: wangweidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next 2/5] sctp: remove the else path
Date: Mon, 11 Nov 2013 09:57:37 +0800
Message-ID: <52803991.2000902@huawei.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com> <1383879310-22792-3-git-send-email-wangweidong1@huawei.com> <527D3949.2000302@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:50670 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab3KKB7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 20:59:03 -0500
In-Reply-To: <527D3949.2000302@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/9 3:19, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/08/2013 05:55 AM, Wang Weidong wrote:
> 
>> Make the code more simplification.
> 
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/sctp/associola.c | 4 +---
>>   1 file changed, 1 insertion(+), 3 deletions(-)
> 
>> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>> index 667f984..2d53d4c 100644
>> --- a/net/sctp/associola.c
>> +++ b/net/sctp/associola.c
>> @@ -954,15 +954,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
>>    */
>>   struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
>>   {
>> -    struct sctp_chunk *chunk;
>> +    struct sctp_chunk *chunk = NULL;
>>
>>       /* Send ECNE if needed.
>>        * Not being able to allocate a chunk here is not deadly.
>>        */
>>       if (asoc->need_ecne)
>>           chunk = sctp_make_ecne(asoc, asoc->last_ecne_tsn);
>> -    else
>> -        chunk = NULL;
> 
>    This is hardly better/simpler than it was.
> 
> WBR, Sergei
> 

Well, you are right. Joe had suggested a good idea to me. And I had fixed
it in the v2.
Thanks. 

> 
> 
