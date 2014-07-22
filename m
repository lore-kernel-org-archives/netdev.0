From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 22 Jul 2014 18:10:07 +0800
Message-ID: <CAJxxZ0M5EPY028e_BZHEcyiWibZCeZ1rVq3junawETRb13FUGw@mail.gmail.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	<1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140722.010105.2036198226851589509.davem@davemloft.net>
	<CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
	<1406022666.10255.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:64839 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbaGVKKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:10:07 -0400
Received: by mail-oa0-f47.google.com with SMTP id g18so9301143oah.34
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:10:07 -0700 (PDT)
In-Reply-To: <1406022666.10255.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 5:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-07-22 at 16:53 +0800, Sonic Zhang wrote:
>
>> if (!--A)
>>
>> doesn't equal to
>>
>> if (A--)
>>         if (!A)
>
> It really does, no matter what you think.
>
> In all cases, A is decremented.
>
> In all cases, final action is done if and only if A was 1 before the
> test(s)
>
> Thats simple logic, and all your arguments about NAPI, IRQ, and moon
> phase are irrelevant.
>

Thank you for correcting. I think I made a mistake on the condition logic.

Regards,

Sonic
