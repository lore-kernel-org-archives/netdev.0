From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with
 IPv6 Neighbor Discovery
Date: Thu, 22 Aug 2013 09:39:45 +0400
Message-ID: <CAOp4FwTcJX4dy23oZv6bU-+Fe-ZmwXp0WGonXVC_xvqPhpmxFQ@mail.gmail.com>
References: <20130813221321.AEA1AB1E003@rfc-editor.org>
	<520B3D81.9070506@gont.com.ar>
	<20130814230617.GA13066@order.stressinduktion.org>
	<520C7519.1010000@gont.com.ar>
	<20130815100407.GA18564@order.stressinduktion.org>
	<CAOp4FwRx3c3deHXupWg3S0aWe4ZJnCT9ORKCWRvUUuxxt1gneQ@mail.gmail.com>
	<20130815102507.GA24122@order.stressinduktion.org>
	<CAOp4FwTPuY9H=w_A7vdwiJv3RqKLWnf+Nk=q8xaa9sN6+g4j1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Loganaden Velvindron <loganaden@gmail.com>,
	Fernando Gont <fernando@gont.com.ar>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:35086 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465Ab3HVFjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 01:39:46 -0400
Received: by mail-we0-f169.google.com with SMTP id t61so1236628wes.0
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 22:39:45 -0700 (PDT)
In-Reply-To: <CAOp4FwTPuY9H=w_A7vdwiJv3RqKLWnf+Nk=q8xaa9sN6+g4j1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 19, 2013 at 12:52 AM, Loganaden Velvindron
<loganaden@gmail.com> wrote:
> On Thu, Aug 15, 2013 at 2:25 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>>
>> On Thu, Aug 15, 2013 at 02:14:46PM +0400, Loganaden Velvindron wrote:
>> > I'm not sure if you got my previous mails, but I'd like to know a
>> > couple of things:
>>
>> Ah, you asked me off-list. So, for a wider audience, I copy & paste my answers
>> from the just answered mail. ;)
>>
>> > 1) How can I test this diff ?
>>
>> Actually, nothing should change at all.
>>
>> Myself, I used scapy to construct some packets and send it to a system
>> with the patched kernel and had some printks sprinkeled in the source
>> while watching tcpdump.
>>
>> > 2) It's developed against which git brach ? linux-next ?
>>
>> Yes, I targeted linux-next. But it should apply to older kernels
>> without too much fuzz as well.
>>
>
> I've tested with linux-next.
>
>> > 3) What will/could break with this diff in a production environment ?
>>
>> RA messages could get fragmented if a speaker puts lots of options in it. I
>> hope all RA speakers already spread the options over multiple RAs, but I don't
>> know. In case the RA is fragmented it will now be dropped silently.
>>
>
> My IPv6 gateway machine runs OpenBSD, and so far, no issues with it.
> I'm going to test
> it at work in a couple of hours and report back.

Works fine @ work with cisco routers.

>
>
>> Thanks,
>>
>>   Hannes
>>
>
>
>
> --
> This message is strictly personal and the opinions expressed do not
> represent those of my employers, either past or present.



-- 
This message is strictly personal and the opinions expressed do not
represent those of my employers, either past or present.
