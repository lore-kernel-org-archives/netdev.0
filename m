From: figo zhang <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 5 Mar 2010 14:54:44 +0800
Message-ID: <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f186.google.com ([209.85.223.186]:58700 "EHLO
	mail-iw0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab0CEGyp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:54:45 -0500
Received: by iwn16 with SMTP id 16so2415701iwn.20
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:54:44 -0800 (PST)
In-Reply-To: <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/3/4 Yegor Yefremov <yegorslists@googlemail.com>:
>>>> I'm using 2.6.33 kernel and I noticed such a strange behavior:
>>>>
>>>> after system start I transfer one file via netcat from my developm=
ent
>>>> host, after this transfer the network is not functioning i.e. no p=
ings
>>>> possible etc.
>>>>
>>>> To narrow down the problem I checked out this commit
>>>>
>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommit;h=3D451f14439847db302e5104c44458b2dbb4b1829d.
>>>> Till here the network driver is functioning as intended, but after
>>>> NAPI introduction I have this issue. With latest git-pull of "Linu=
s'
>>>> kernel tree" I can't even ping right after the systems start.
>>>>
>>>> Any Ideas? What am I missing?
>>>>
>>>
>>> No idea, although I am using the same ARM chip, my kernel is at 2.6=
=2E30.5,
>>> and except for this occasional loss of connection I get, the ethern=
et driver
>>> seems to work better than what you are reporting.
>>
>> from linux-2.6.32, this ethernet =A0driver have add NAPI support, wo=
uld
>> you like to
>> try using this version?
>
> Figo, I just looked at the 2.6.32 kernel and found out that it
> doesn't' contain NAPI support (see the history
> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.32.y.git=
;a=3Dhistory;f=3Ddrivers/net/arm/ks8695net.c;h=3D2a7b7745cc55b54cefada6=
90b0ea47865b54b6b9;hb=3DHEAD).
> So 2.6.33 is the first stable kernel to support NAPI.
>
> I made some further tests but I can't find the reason for network
> failures: the interrupts are coming and the packets will be received
> and sent so that rx/tx counters would be increased, but none of them
> seem to reach the IP stack. I don't know where and why the things get
> desynchronized.
>
> Could you try the 2.6.33 or Linus tree? Thank you in advance.

yes, i have test it on linux-2.6.33, it is work well.
