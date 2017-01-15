From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v3 1/1] net sched actions: Add support for user
 cookies
Date: Sun, 15 Jan 2017 10:18:20 -0500
Message-ID: <ac5fe140-e52a-ff5c-dafe-2d6841b07560@mojatatu.com>
References: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
 <1484488879-29560-2-git-send-email-jhs@emojatatu.com>
 <20170115150133.GA1774@nanopsycho.orion>
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
Received: from mail-it0-f67.google.com ([209.85.214.67]:34770 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751114AbdAOPSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 10:18:30 -0500
Received: by mail-it0-f67.google.com with SMTP id o185so9900615itb.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 07:18:24 -0800 (PST)
In-Reply-To: <20170115150133.GA1774@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-15 10:01 AM, Jiri Pirko wrote:
> Sun, Jan 15, 2017 at 03:01:19PM CET, jhs@mojatatu.com wrote:

>> +cls_set_class(struct tcf_proto *tp, unsigned long *clp,
>
> ??
>
>> 	unsigned long cl)
>> {
>> 	unsigned long old_cl;
>> -	
>> +
>
> ??
>
>> 	tcf_tree_lock(tp);
>> 	old_cl = __cls_set_class(clp, cl);
>> 	tcf_tree_unlock(tp);
>> -
>> +
>
> ??
>
>> 	return old_cl;
>> }
>>
>> @@ -237,7 +237,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
>>
>> 	return 0;
>> }
>> -	
>> +
>
> ??
>

All these things with "??" were annoying whitespace and stylistic
things my fingers couldnt resist. It is legit to include such changes
in a patch when touching the code (as long as not a bug fix).

cheers,
jamal
