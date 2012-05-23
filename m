From: Sergio Correia <lists@uece.net>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Wed, 23 May 2012 15:30:24 -0300
Message-ID: <CAJyhjX1E_yzT1Vte+3iqc-PnfLiEEdFEyM9GcOCs-6TrUm86XQ@mail.gmail.com>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
 <1337697203.3361.190.camel@edumazet-glaptop> <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
 <1337785681.3361.2923.camel@edumazet-glaptop> <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
 <1337791018.3361.3024.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:43533 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760659Ab2EWSap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 14:30:45 -0400
Received: by gglu4 with SMTP id u4so6835246ggl.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 11:30:44 -0700 (PDT)
In-Reply-To: <1337791018.3361.3024.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 23, 2012 at 1:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2012-05-23 at 12:56 -0300, Sergio Correia wrote:
>> On Wed, May 23, 2012 at 12:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2012-05-22 at 11:47 -0300, Sergio Correia wrote:
>> >> Hi Eric,
>> > ...
>> >> Yes, it's an Atheros AR9285 adapter.
>> >> This morning I did a make mrproper before rebuilding the kernel
>> >> (should I always do that?), but the warning has just appeared again.
>> >
>> > OK, I am taking a look at this problem, thanks.
>> >
>>
>> Thanks. Let me know if you need additional info. As of now, my dmesg
>> basically shows only those warnings.
>
> I believe I found the bug and am testing a fix right now.
>
> By the way, we might have the same problem in tcp collapses.
>
> TCP coalescing (introduced in linux-3.5) triggers the problem faster.
>
> Please test following patch :
>

I reverted back to 471368557a734c6c486ee757952c902b36e7fd01 and it
took almost one hour to trigger the warning. Now I have applied your
patch and will report back how it went after a few hours of testing.
