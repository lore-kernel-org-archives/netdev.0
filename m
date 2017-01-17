From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/2] net sched: Trivial whitespace and
 stylistic changes
Date: Tue, 17 Jan 2017 11:30:55 -0500
Message-ID: <2d5f2812-3bdc-fe05-6b32-6c10738550bd@mojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-3-git-send-email-jhs@emojatatu.com>
 <20170117121231.GB1807@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33929 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdAQQbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:31:02 -0500
Received: by mail-qt0-f193.google.com with SMTP id a29so22679103qtb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 08:31:02 -0800 (PST)
In-Reply-To: <20170117121231.GB1807@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jiri,

I am going to drop this patch altogether. Someday i will do the cleanup.

cheers,
jamal

On 17-01-17 07:12 AM, Jiri Pirko wrote:
> Tue, Jan 17, 2017 at 12:11:49PM CET, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>
> [...]
> 	
>> -static inline unsigned long
>> -cls_set_class(struct tcf_proto *tp, unsigned long *clp,
>> +static inline unsigned long cls_set_class(struct tcf_proto *tp,
>> +					  unsigned long *clp,
>> 	unsigned long cl)
>
> While you are at it, you can align this as well.
>
>
>> {
>> 	unsigned long old_cl;
>> -	
>
> This empty line should definitelly stay.
>
>
>> 	tcf_tree_lock(tp);
>> 	old_cl = __cls_set_class(clp, cl);
>> 	tcf_tree_unlock(tp);
>> -
>> 	return old_cl;
>> }
>>
>
> [...]
>
>> @@ -237,7 +232,6 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
>>
>> 	return 0;
>> }
>> -	
>
> This empty line should stay.
>
>
>> /**
>>  * struct tcf_ematch_tree - ematch tree handle
>>  *
>> @@ -246,8 +240,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
>>  */
>> struct tcf_ematch_tree {
>> 	struct tcf_ematch_tree_hdr hdr;
>> -	struct tcf_ematch *	matches;
>> -	
>> +	struct tcf_ematch	*matches;
>
> Well, to be pedantic, this still looks odd :)
>
>
>> };
