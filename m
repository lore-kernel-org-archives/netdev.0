From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Wed, 3 Mar 2010 09:28:12 +0100
Message-ID: <f69abfc31003030028x500796aav21295da78743da07@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <4B8DED29.9000605@softplc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: figo zhang <figo1802@gmail.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Dick Hollenbeck <dick@softplc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:52111 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab0CCI2R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:28:17 -0500
Received: by ewy20 with SMTP id 20so769853ewy.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 00:28:15 -0800 (PST)
In-Reply-To: <4B8DED29.9000605@softplc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
>>>>
>>>
>>> No idea, although I am using the same ARM chip, my kernel is at 2.6=
=2E30.5,
>>> and except for this occasional loss of connection I get, the ethern=
et
>>> driver
>>> seems to work better than what you are reporting.
>>>
>>
>> from linux-2.6.32, this ethernet =C2=A0driver have add NAPI support,=
 would
>> you like to
>> try using this version?
>>
>
> Seems like a lot of work for me, given that my 2.6.30.5 kernel is mos=
tly
> working. =C2=A0 Yegor is having the problems on the newer kernels, ne=
wer than
> mine. =C2=A0Sounds like a warning flag to me, not an incentive.
>
> What is NAPI and why do I care?

Here is Wikipedia article: http://en.wikipedia.org/wiki/NAPI

The problem also is that I really need a kernel version not less than
2.6.33 because of the support of other platforms.

I sniffed a little with wireshark and the symptoms are the following:

after netcat transfer the system sends only ARP requests and no other p=
ackets.

I just git-pulled the latest Linus tree and the network still has the
above described issues.

=46igo, could you test the latest kernel with netcat transfers? So you
could reproduce this behavior?

Yegor
