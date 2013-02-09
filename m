From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Softirqs without captured packets
Date: Sat, 9 Feb 2013 21:27:30 +0100
Message-ID: <CALZVapn-oF2L1BB855x26XGjzP6wYyT93jcJB0X3TcmFE8AxYA@mail.gmail.com>
References: <CALZVapktiq5norswRmjZyGXpx7mYdaTgQvJ50vO2UjsJ=pf1=w@mail.gmail.com>
 <20130208.145728.1110053781319882182.davem@davemloft.net> <CALZVapnbVoZ_G_viipXwm3vZC5Qkq1zwmfnf3ydvLjdjEa_8Zg@mail.gmail.com>
 <20130208.151523.798634382725569230.davem@davemloft.net> <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f179.google.com ([209.85.128.179]:51741 "EHLO
	mail-ve0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932527Ab3BIU1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 15:27:51 -0500
Received: by mail-ve0-f179.google.com with SMTP id da11so4301498veb.10
        for <netdev@vger.kernel.org>; Sat, 09 Feb 2013 12:27:50 -0800 (PST)
In-Reply-To: <CALZVap=-=4Wmo3Pha54rL65zMuxt5=5ti5Abm44TJF73ehe_Vg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you tell me something about the traces I introduced?

I tried to insert the trace the cleanest way possible. I patched
dev.c, in the measurement places and tried to make the module the more
independent I could. It makes the measure with sched_clock() and in
each round, it sums up the work done.

I have supposed that that softirq is just for capturing packets, so
that is why I asked my first question,

Waiting your reply,

Javier Domingo


2013/2/8 Javier Domingo <javierdo1@gmail.com>:
> This is the patch to enable the tracer module, programed for version
> v3.6 in the mainline.
>
> It is part of a bigger project I am trying to release, but I am not
> still authorized to release other's source code. The sourcecode
> contained here is just mine, and I release it under GPLv3.
>
> Hope it works without any modification! git apply worked for me.
>
> Cheers and thank you for your attention,
> Javier Domingo
>
>
> 2013/2/8 David Miller <davem@davemloft.net>:
>> From: Javier Domingo <javierdo1@gmail.com>
>> Date: Fri, 8 Feb 2013 21:02:41 +0100
>>
>>> Sorry, I think I misexplained,
>>>
>>> I wanted to say net's receive softirq: net_rx_action, not softirqs in general.
>>
>> If you don't show us your code we have to guess all sorts of things
>> like this.
>>
>> Don't expect much help until you post your tracer module.
