From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 1/1] net sched actions: Add support for user
 cookies
Date: Sun, 22 Jan 2017 20:32:08 +0100
Message-ID: <20170122193208.GC1797@nanopsycho.orion>
References: <1485089498-6673-1-git-send-email-jhs@emojatatu.com>
 <1485089498-6673-2-git-send-email-jhs@emojatatu.com>
 <11da08ed-32b3-2a9f-8ba4-54b346cabecc@gmail.com>
 <57017269-891c-6347-33e5-600fe8b1726e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33405 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdAVTcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 14:32:41 -0500
Received: by mail-wm0-f65.google.com with SMTP id r144so21166638wme.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 11:32:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <57017269-891c-6347-33e5-600fe8b1726e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jan 22, 2017 at 07:57:17PM CET, jhs@mojatatu.com wrote:
>On 17-01-22 01:13 PM, Florian Fainelli wrote:
>> 
>> 
>
>> 
>> > +		a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE],
>> > +						 GFP_KERNEL);
>> > +		if (!a->act_cookie->data) {
>> > +			err = -ENOMEM;
>> > +			tcf_hash_release(a, bind);
>> > +			goto err_mod;
>> > +		}
>> 
>> Are not you leaking a->act_cookie here in case nla_memdup() fails here?
>> 
>
>yes, I am. Thanks for catching this. V6 coming up.

Btw, you don't have to send cover letter for a single patch. In fact, you
should not.
