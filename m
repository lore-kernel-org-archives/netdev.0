From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v3 05/11] openvswitch: Add recirc action
Date: Wed, 16 Jul 2014 09:14:26 -0700
Message-ID: <CALnjE+qSiTWK-jJV0+22YxV04P8tVMrDTE1uGs_VymVW8j5nqQ@mail.gmail.com>
References: <1405495932-2076-1-git-send-email-pshelar@nicira.com>
	<1405501650.10255.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:41294 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965325AbaGPQO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 12:14:27 -0400
Received: by mail-vc0-f176.google.com with SMTP id ik5so2083630vcb.7
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 09:14:26 -0700 (PDT)
In-Reply-To: <1405501650.10255.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 2:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-07-16 at 00:32 -0700, Pravin B Shelar wrote:
>> From: Andy Zhou <azhou@nicira.com>
>>
>> Recirculation implementation for Linux kernel data path.
>
>
> This is a very lame changelog if you ask me.
>
> Does it involve recursion ?
>
Yes, recursion is used. That why earlier patch in same series exports
xmit_recursion. It limits total number recursions in networking stack
to RECURSION_LIMIT.


> Its really not clear reading the patch what is going on here.
>
OK, I will update commit msg.
