From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless 2011-12-15
Date: Fri, 16 Dec 2011 07:40:16 +0100
Message-ID: <CACna6rz3qDpw4eJOoCXx7=z1719v7kS-Ou-WUseR9_vB-O2dag@mail.gmail.com>
References: <20111215191523.GA2561@tuxdriver.com>
	<CACna6rw736JdkoM8zKxorCFd5oy08QTwWZ6PutoJPSr3ZN8hTg@mail.gmail.com>
	<20111215213822.GB2561@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arend Van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111215213822.GB2561-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

W dniu 15 grudnia 2011 22:38 u=C5=BCytkownik John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> napisa=C5=82:
> On Thu, Dec 15, 2011 at 09:04:29PM +0100, Rafa=C5=82 Mi=C5=82ecki wro=
te:
>> 2011/12/15 John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
>> > commit 42a3b63bb2ca4996a3d1210a004eae2333f1119e
>> >
>> > Dave,
>> >
>> > Here are a few more fixes intended for the 3.2 release. =C2=A0They=
 are
>> > all small and narrowly focused.
>>
>> John, I've made a mistake and didn't use [PATCH 3.2] header to make =
it
>> clean my patch is fix. Could you take a look at
>> [PATCH] bcma: support for suspend and resume
>> please?
>>
>> It's not one-liner, but fixes lock ups, which I believe - we really
>> want to avoid.
>
> It's late in the release cycle, and Dave specifically asked me to slo=
w down.
>
> Are these suspend/resume lockups a regression? =C2=A0Or have they alw=
ays
> been there? =C2=A0Do they happen to everyone?

The bug is present since first days of bcma. That's why I even decided
to add stable to CC.

Personally I've tested that only on 1 machine (I don't have more
suspendable machines with mini PCIe slot). However all Macbook 8.1/8.2
users have to remove b43 & bcma before suspending [0], they complain
about that since ever.

Arend: I know you're also complaining for suspend in bcma. Can you
comment on this?

[0] http://ubuntuforums.org/showthread.php?t=3D1695746

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
