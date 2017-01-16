From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 1/1] net sched actions: Add support for user
 cookies
Date: Mon, 16 Jan 2017 08:27:54 +0100
Message-ID: <20170116072754.GA1804@nanopsycho.orion>
References: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
 <1484488879-29560-2-git-send-email-jhs@emojatatu.com>
 <20170115150133.GA1774@nanopsycho.orion>
 <ac5fe140-e52a-ff5c-dafe-2d6841b07560@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34755 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdAPH16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 02:27:58 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so28542632wmi.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 23:27:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ac5fe140-e52a-ff5c-dafe-2d6841b07560@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jan 15, 2017 at 04:18:20PM CET, jhs@mojatatu.com wrote:
>On 17-01-15 10:01 AM, Jiri Pirko wrote:
>> Sun, Jan 15, 2017 at 03:01:19PM CET, jhs@mojatatu.com wrote:
>
>> > +cls_set_class(struct tcf_proto *tp, unsigned long *clp,
>> 
>> ??
>> 
>> > 	unsigned long cl)
>> > {
>> > 	unsigned long old_cl;
>> > -	
>> > +
>> 
>> ??
>> 
>> > 	tcf_tree_lock(tp);
>> > 	old_cl = __cls_set_class(clp, cl);
>> > 	tcf_tree_unlock(tp);
>> > -
>> > +
>> 
>> ??
>> 
>> > 	return old_cl;
>> > }
>> > 
>> > @@ -237,7 +237,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
>> > 
>> > 	return 0;
>> > }
>> > -	
>> > +
>> 
>> ??
>> 
>
>All these things with "??" were annoying whitespace and stylistic
>things my fingers couldnt resist. It is legit to include such changes
>in a patch when touching the code (as long as not a bug fix).

Well, I think you should change this in a separate patch as it has 0
relation with this patch.
