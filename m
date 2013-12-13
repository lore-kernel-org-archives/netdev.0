From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 10:33:50 -0800
Message-ID: <CAM_iQpVgo+nxN3eTRg_F9u+-k4ML+D3ZqsrAEOeLZwtU6dOk3g@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:52456 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470Ab3LMSdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:33:50 -0500
Received: by mail-ob0-f169.google.com with SMTP id wm4so2368654obc.28
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:33:50 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7489@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 2:21 AM, David Laight <David.Laight@aculab.com> wrote:
>> From: Cong Wang
>>
>> It is not used.
> ...
>> --- a/include/net/act_api.h
>> +++ b/include/net/act_api.h
>> @@ -72,7 +72,6 @@ struct tc_action_ops {
>>       __u32   capab;  /* capabilities includes 4 bit version */
>>       struct module           *owner;
>>       int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
>> -     int     (*get_stats)(struct sk_buff *, struct tc_action *);
>>       int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
>>       int     (*cleanup)(struct tc_action *, int bind);
>>       int     (*lookup)(struct tc_action *, u32);
>
> Deleting a field out of the middle of a list of function pointers
> seems dangerous.

Why? Keep in mind that we don't need to worry about any
out-of-tree modules. :)
