From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 5/5] ISDN-CAPI: Delete unnecessary braces
Date: Mon, 26 Sep 2016 14:52:39 +0200
Message-ID: <e2f45ffb-9440-19c6-b7ce-0894dcd14879@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
 <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
 <52dd5000-2bda-a1b6-aa97-1868e1193d35@cogentembedded.com>
 <727b14d4-7a3b-9de8-25d9-c3bf212f7c44@users.sourceforge.net>
 <1474881642.1846.14.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474881642.1846.14.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> @@ -976,13 +974,12 @@ static void handle_controller(_cmsg *cmsg)
>>>>          if (debugmode)
>>>>              printk(KERN_DEBUG "capidrv-%d: listenconf Info=0x%4x
>>>> (%s) cipmask=0x%x\n",
>>>>                     card->contrnr, cmsg->Info,
>>>> capi_info2str(cmsg->Info), card->cipmask);
>>>> -        if (cmsg->Info) {
>>>> +        if (cmsg->Info)
>>>>              listen_change_state(card, EV_LISTEN_CONF_ERROR);
>>>> -        } else if (card->cipmask == 0) {
>>>> +        else if (card->cipmask == 0)
>>>>              listen_change_state(card, EV_LISTEN_CONF_EMPTY);
>>>> -        } else {
>>>> +             else
>>>
>>>    Indented too much.
>>
>> How do you think about an alignment of this "else"
>> with the corresponding if statement three lines above?
> 
> Well, I think it looks silly.

Thanks for your feedback.


> checkpatch apparently agrees:
>     WARNING: Statements should start on a tabstop
>     #51: FILE: drivers/isdn/capi/capidrv.c:981:
>     +		     else
>     
>     total: 0 errors, 1 warnings, 91 lines checked
…
> You use checkpatch a lot, don't you?

It seems so when I am preparing hundreds of update steps.


> Didn't you use it to, you know, check your patch?

This Perl script showed me also the quoted information.

I dared to present a deviation from this general advice
because I got the mood to gather constructive comments on
source code formatting also around an if statement like
in my update suggestion.

Would it eventually make sense to move this "if" (behind an "else")
to a separate line and increase the indentation for the corresponding
code one level then?

Regards,
Markus
