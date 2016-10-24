From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 10:48:58 +0200
Message-ID: <20161024084858.GD2781@nanopsycho>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
 <580D3A14.5010705@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33802 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934737AbcJXItB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 04:49:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id d199so8723304wmd.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 01:49:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <580D3A14.5010705@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 24, 2016 at 12:30:44AM CEST, daniel@iogearbox.net wrote:
>On 10/23/2016 05:35 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> 
>
>An actual commit message would be good especially if it's a fix
>for -net tree plus stable. Thanks.

Also a "Fixes:" tag would be nice to have :)


>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>>   net/sched/cls_api.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 2ee29a3..2b2a797 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>>   			if (err == 0) {
>>   				struct tcf_proto *next = rtnl_dereference(tp->next);
>> 
>> -				tfilter_notify(net, skb, n, tp, fh,
>> +				tfilter_notify(net, skb, n, tp,
>> +					       t->tcm_handle,
>>   					       RTM_DELTFILTER, false);
>>   				if (tcf_destroy(tp, false))
>>   					RCU_INIT_POINTER(*back, next);
>> 
>
