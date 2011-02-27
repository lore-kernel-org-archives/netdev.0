From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 16:38:17 +0100
Message-ID: <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
References: <20110225222210.GA3618@tuxdriver.com>
	<AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
	<87fwr9jxya.fsf@cruithne.co.teklibre.org>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	bloat-devel@lists.bufferbloat.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Dave_T=C3=A4ht?= <d@taht.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:41733 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab1B0PiS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 10:38:18 -0500
In-Reply-To: <87fwr9jxya.fsf@cruithne.co.teklibre.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 27, 2011 at 4:31 PM, Dave T=C3=A4ht <d@taht.net> wrote:
>
> Sedat Dilek <sedat.dilek@googlemail.com> writes:
>
>> On Fri, Feb 25, 2011 at 11:22 PM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>>> Announcement
>>>
>>> The bufferbloat project [1] is pleased to announce the availability
>>> of the debloat-testing Linux kernel git tree:
>>>
>>> =C2=A0 git://git.infradead.org/debloat-testing.git
>
> ----snip----
>
>> Hi,
>>
>> it should be "localversion-debloat" in the commit-subject in [1] (no=
t
>> "localversion-wireless") :-). =C2=A0"-db" as suffix is IMHO not very
>> meaningful... Why not add simply a suffix called "-debloat"? =C2=A0(=
Anyway,
>> I will revert this patch because I don't want to have any suffix add=
ed
>> automatically.)
>>
>> I have several other questions, but I start compiling first and test
>> this debloat kernel.
>
> Excellent. At moment I would recommend building "low latency preempt
> desktop" kernels with a high HZ value (400 or 1000), enabling highres
> timers, and compiling in SFB as a module. (I'd like the default for S=
=46B
> to be "m" rather than "n", too)
>
>>
>> Regards,
>> - Sedat -
>>
>> [1] "Add localversion-wireless to identify builds from this tree."
>> http://git.infradead.org/debloat-testing.git/commit/3f9bdb4f44b076fe=
da72d353d8ad717831416f36
>> _______________________________________________
>> Bloat-devel mailing list
>> Bloat-devel@lists.bufferbloat.net
>> https://lists.bufferbloat.net/listinfo/bloat-devel
>
> --
> Dave Taht
> http://nex-6.taht.net
>

These "debloat guys" are fast :-).
I was just preparing my build-system (which I normally use to
debianize linux-next kernels).
Any other recommendation for kernel-config options?
=46or example:
linux-next has already CONFIG_NET_SCH_CHOKE (but I have unset it).
Which commits are in debloat-testing GIT but not in linux-next tree?
Are you planning debloat feature for 2.6.39?

- Sedat -
