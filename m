From: d@taht.net (Dave =?utf-8?Q?T=C3=A4ht?=)
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 08:56:48 -0700
Message-ID: <8739n9ii7z.fsf@cruithne.co.teklibre.org>
References: <20110225222210.GA3618@tuxdriver.com>
	<AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
	<87fwr9jxya.fsf@cruithne.co.teklibre.org>
	<AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	bloat-devel@lists.bufferbloat.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
	(Sedat Dilek's message of "Sun, 27 Feb 2011 16:38:17 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sedat Dilek <sedat.dilek@googlemail.com> writes:

> On Sun, Feb 27, 2011 at 4:31 PM, Dave T=C3=A4ht <d@taht.net> wrote:
>>
>> Sedat Dilek <sedat.dilek@googlemail.com> writes:
>>
>>> On Fri, Feb 25, 2011 at 11:22 PM, John W. Linville
>>> <linville@tuxdriver.com> wrote:
>>>> Announcement
>>>>
>>>> The bufferbloat project [1] is pleased to announce the availabilit=
y
>>>> of the debloat-testing Linux kernel git tree:
>>>>
>>>> =C2=A0 git://git.infradead.org/debloat-testing.git
>>
>> ----snip----

>> Excellent. At moment I would recommend building "low latency preempt
>> desktop" kernels with a high HZ value (400 or 1000), enabling highre=
s
>> timers, and compiling in SFB as a module. (I'd like the default for =
SFB
>> to be "m" rather than "n", too)
>>

> These "debloat guys" are fast :-).  I was just preparing my
> build-system (which I normally use to debianize linux-next kernels).
> Any other recommendation for kernel-config options?  For example:
> linux-next has already CONFIG_NET_SCH_CHOKE (but I have unset it).

Enable CHOKe.

The HZ value change is due to my worry that we've smashed latency so
much in the driver/mac layer that it's interacting with the higher
layers somewhat badly... So we need to add more hooks to the servo loop=
s
involved in order to have a normal HZ.=20

> Which commits are in debloat-testing GIT but not in linux-next tree?

The current list was in the release announcement. More on the way
(mostly embedded drivers at this point) git pull early and often!

> Are you planning debloat feature for 2.6.39?

Depends on how many testers we get and what the results are.=20

I feel the eBDP stuff will not be ready during this release cycle. SFB
and CHOKe are in net-next, so, probably. Various driver patches -
particularly those that increase the available dynamic range via
ethtool, (e.g lowering the bottommost TX queue limit to, like, 4,
especially for home gateways) may make it out if people look harder int=
o
the issue.

>
> - Sedat -

--=20
Dave Taht
http://nex-6.taht.net
