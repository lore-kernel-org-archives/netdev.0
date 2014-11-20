From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Thu, 20 Nov 2014 13:57:00 -0800
Message-ID: <CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	<1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<546C4022.5010509@oracle.com>
	<CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
	<1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
	<1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wengang <wen.gang.wang@oracle.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:57683 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100AbaKTV5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 16:57:02 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so963235wib.1
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 13:57:01 -0800 (PST)
In-Reply-To: <1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 12:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-11-20 at 09:34 -0800, Cong Wang wrote:
>
>> I didn't look into ipoib_header_ops, thought it might have some dependency
>> on symbols.
>
> I did look before answering and suggesting this, you really should do
> the same instead of giving advices of over engineering the stack.
>
> Best is the enemy of the good.
>
> Its hard to find some networking function trivial than this one.

What about other modules defining *header_ops? Don't they
need to move to vmlinux as well?

I still don't like this workaround even just for stable. Although
definitely a real fix could be harder to backport, for me it is normal
backport 8+ patches to stable:

http://www.spinics.net/lists/stable/msg66122.html
http://www.spinics.net/lists/linux-fsdevel/msg79967.html

I know you disagree, I don't even want to waste time on arguing it.
