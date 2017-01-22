From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/1] net sched actions: Add support for user
 cookies
Date: Sun, 22 Jan 2017 14:44:50 -0500
Message-ID: <6fcf044a-5112-a1e2-4ee5-643cab8100e7@mojatatu.com>
References: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
 <1485089498-6673-2-git-send-email-jhs@emojatatu.com>
 <11da08ed-32b3-2a9f-8ba4-54b346cabecc@gmail.com>
 <57017269-891c-6347-33e5-600fe8b1726e@mojatatu.com>
 <20170122193208.GC1797@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36601 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751299AbdAVTo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 14:44:58 -0500
Received: by mail-qt0-f193.google.com with SMTP id l7so12578730qtd.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 11:44:57 -0800 (PST)
In-Reply-To: <20170122193208.GC1797@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-22 02:32 PM, Jiri Pirko wrote:
> Sun, Jan 22, 2017 at 07:57:17PM CET, jhs@mojatatu.com wrote:
>> On 17-01-22 01:13 PM, Florian Fainelli wrote:
>>>
>>>
>>
>>>
>>>> +		a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE],
>>>> +						 GFP_KERNEL);
>>>> +		if (!a->act_cookie->data) {
>>>> +			err = -ENOMEM;
>>>> +			tcf_hash_release(a, bind);
>>>> +			goto err_mod;
>>>> +		}
>>>
>>> Are not you leaking a->act_cookie here in case nla_memdup() fails here?
>>>
>>
>> yes, I am. Thanks for catching this. V6 coming up.
>
> Btw, you don't have to send cover letter for a single patch. In fact, you
> should not.
>

You can see i write small novels in my commit logs. Do you suggest i
put the git history there as well?

cheers,
jamal
