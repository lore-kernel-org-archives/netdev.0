From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v12 1/4] net netlink: Add new type NLA_BITFIELD32
Date: Mon, 31 Jul 2017 14:21:06 +0200
Message-ID: <20170731122106.GD1883@nanopsycho>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-2-git-send-email-jhs@emojatatu.com>
 <20170730184242.GA1872@nanopsycho>
 <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
 <20170731063833.GB1883@nanopsycho>
 <fa171203-adab-9950-8241-dd5b3a70fe0a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33405 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdGaMVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 08:21:08 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so31357511wrd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 05:21:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fa171203-adab-9950-8241-dd5b3a70fe0a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 31, 2017 at 02:03:55PM CEST, jhs@mojatatu.com wrote:
>On 17-07-31 02:38 AM, Jiri Pirko wrote:
>> Sun, Jul 30, 2017 at 09:59:10PM CEST, jhs@mojatatu.com wrote:
>> > Jiri,
>> > 
>> > This is getting exhausting, seriously.
>> > I posted the code you are commenting one two days ago so i dont have to
>> > repost.
>> 
>> And I commented on the "*u32 = *u32" thing. But you ignored it. Pardon
>> me for mentioning that again now :/
>> 
>
>You commented on *u32 assignment from *void which i fixed. I
>intentionally selected the different assignment names to reflect
>meaning. Had you commented earlier - although I would have found

Yep, I don't understand why the function arg cannot have the desired
name right away. Also, I don't understand why you don't just have u32
instead of pointer as a local variable, if you really needed this local
variable. Ok, I admit that ":)" is probably not intuitive comment.
Will be more blunt next time.


>it disagreable - I would have fixed that too. Jiri, you need to be
>more tolerant so progress can be made at times.

I don't think so. I believe that it is really important that code can be
read nicely. If we don't do it, it will be just mess (like it is in lot
of net/sched/ places).


>
>> 
>> > 
>> > On D. Ahern: I dont think we are disagreeing anymore on the need to
>> > generalize the check. He is saying it should be a helper and I already
>> > had the validation data; either works. I dont see the gapping need
>> > to remove the validation data.
>> 
>> DavidA? Your opinion.
>> 
>
>With DavidA(reading his response) - the issue is one of taste.
>Again either approach is fine. You can call helpers for every user
>or make them invoked behind the scenes.
>Again - like all your comments on code taste which I addressed, I
>would have made that change if the comment had come in earlier. I got
>exhausted. Imagine how a newbie corporate guy wouldve felt after this.

That's how it is. 
