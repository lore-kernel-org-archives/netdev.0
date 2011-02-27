From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 17:01:27 +0100
Message-ID: <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
References: <20110225222210.GA3618@tuxdriver.com>
	<AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
	<87fwr9jxya.fsf@cruithne.co.teklibre.org>
	<AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
	<8739n9ii7z.fsf@cruithne.co.teklibre.org>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Dave_T=C3=A4ht?= <d@taht.net>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8739n9ii7z.fsf-dm88P3lIUJl5IOjekqviT21/HaPePypd@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 27, 2011 at 4:56 PM, Dave T=C3=A4ht <d@taht.net> wrote:
> Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:
>
>> On Sun, Feb 27, 2011 at 4:31 PM, Dave T=C3=A4ht <d@taht.net> wrote:
>>>
>>> Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:
>>>
>>>> On Fri, Feb 25, 2011 at 11:22 PM, John W. Linville
>>>> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>>>>> Announcement
>>>>>
>>>>> The bufferbloat project [1] is pleased to announce the availabili=
ty
>>>>> of the debloat-testing Linux kernel git tree:
>>>>>
>>>>> =C2=A0 git://git.infradead.org/debloat-testing.git
>>>
>>> ----snip----
>
>>> Excellent. At moment I would recommend building "low latency preemp=
t
>>> desktop" kernels with a high HZ value (400 or 1000), enabling highr=
es
>>> timers, and compiling in SFB as a module. (I'd like the default for=
 SFB
>>> to be "m" rather than "n", too)
>>>
>
>> These "debloat guys" are fast :-). =C2=A0I was just preparing my
>> build-system (which I normally use to debianize linux-next kernels).
>> Any other recommendation for kernel-config options? =C2=A0For exampl=
e:
>> linux-next has already CONFIG_NET_SCH_CHOKE (but I have unset it).
>
> Enable CHOKe.
>
> The HZ value change is due to my worry that we've smashed latency so
> much in the driver/mac layer that it's interacting with the higher
> layers somewhat badly... So we need to add more hooks to the servo lo=
ops
> involved in order to have a normal HZ.
>
>> Which commits are in debloat-testing GIT but not in linux-next tree?
>
> The current list was in the release announcement. More on the way
> (mostly embedded drivers at this point) git pull early and often!
>
>> Are you planning debloat feature for 2.6.39?
>
> Depends on how many testers we get and what the results are.
>
> I feel the eBDP stuff will not be ready during this release cycle. SF=
B
> and CHOKe are in net-next, so, probably. Various driver patches -
> particularly those that increase the available dynamic range via
> ethtool, (e.g lowering the bottommost TX queue limit to, like, 4,
> especially for home gateways) may make it out if people look harder i=
nto
> the issue.
>
>>
>> - Sedat -
>
> --
> Dave Taht
> http://nex-6.taht.net
>

OK, thanks for the explanations.

Concerning "more drivers":
What would I have to do to modify ath5k?
I looked into the ath9k patch in debloat-testing GIT and it was to mod
some (TX/BUF) values only.
Not sure if ath9k is/was "well" prepared or only a good choice by the
testers/committers as they own such a device.

- Sedat -
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
