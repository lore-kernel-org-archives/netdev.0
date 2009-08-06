From: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: WARNING: at net/mac80211/mlme.c:2292 ieee80211_sta_work+0x97/0xd2d
	[mac80211]()
Date: Thu, 6 Aug 2009 21:26:07 +0200
Message-ID: <b637ec0b0908061226m33203bco7ac38cecb939b382@mail.gmail.com>
References: <b637ec0b0908061130w399eb1c6oc3a31640a76398c5@mail.gmail.com>
	 <20090806183247.GI26809@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090806183247.GI26809-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John. I'm using ath5k .

The card is a:

01:00.0 Ethernet controller: Atheros Communications Inc. AR5001
Wireless Network Adapter (rev 01)

with PCI ID:

01:00.0 0200: 168c:001c (rev 01)


Regards,
=46abio




On Thu, Aug 6, 2009 at 8:32 PM, John W. Linville<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org=
> wrote:
> What driver are you using?
>
> On Thu, Aug 06, 2009 at 08:30:23PM +0200, Fabio Comolli wrote:
>> Just got this after a resume from suspend-to-ram. Wifi needed to be
>> disabled and reenabled (with hardware Fn+F2 key - this is an eeePC90=
0)
>> to function =C2=A0again.
>>
>>
>> [ =C2=A0919.858759] ------------[ cut here ]------------
>> [ =C2=A0919.858787] WARNING: at net/mac80211/mlme.c:2292
>> ieee80211_sta_work+0x97/0xd2d [mac80211]()
>> [ =C2=A0919.858791] Hardware name: 900
>> [ =C2=A0919.858793] Modules linked in: uvcvideo videodev v4l1_compat=
 arc4
>> ecb ath5k mac80211 ath cfg80211
>> [ =C2=A0919.860022] Pid: 793, comm: phy0 Tainted: G =C2=A0 M =C2=A0 =
=C2=A0 =C2=A0 2.6.31-rc5 #11
>> [ =C2=A0919.860025] Call Trace:
>> [ =C2=A0919.860035] =C2=A0[<c10209cf>] warn_slowpath_common+0x65/0x7=
c
>> [ =C2=A0919.860058] =C2=A0[<f83d621e>] ? ieee80211_sta_work+0x97/0xd=
2d [mac80211]
>> [ =C2=A0919.860064] =C2=A0[<c10209f3>] warn_slowpath_null+0xd/0x10
>> [ =C2=A0919.860086] =C2=A0[<f83d621e>] ieee80211_sta_work+0x97/0xd2d=
 [mac80211]
>> [ =C2=A0919.860092] =C2=A0[<c101bb2b>] ? __wake_up+0x2f/0x56
>> [ =C2=A0919.860097] =C2=A0[<c101bb39>] ? __wake_up+0x3d/0x56
>> [ =C2=A0919.860103] =C2=A0[<c102eb04>] ? insert_work+0x96/0x9f
>> [ =C2=A0919.860108] =C2=A0[<c102ed63>] ? __queue_work+0x32/0x49
>> [ =C2=A0919.860113] =C2=A0[<c102eda1>] ? queue_work_on+0x27/0x2f
>> [ =C2=A0919.860119] =C2=A0[<c102f52f>] ? queue_work+0x2d/0x45
>> [ =C2=A0919.860140] =C2=A0[<f83d3324>] ?
>> ieee80211_ibss_notify_scan_completed+0x63/0x68 [mac80211]
>> [ =C2=A0919.860162] =C2=A0[<f83d1059>] ? ieee80211_scan_completed+0x=
320/0x328 [mac80211]
>> [ =C2=A0919.860184] =C2=A0[<f83d1160>] ? ieee80211_scan_work+0xb5/0x=
171 [mac80211]
>> [ =C2=A0919.860190] =C2=A0[<c102f075>] worker_thread+0x15d/0x204
>> [ =C2=A0919.860211] =C2=A0[<f83d6187>] ? ieee80211_sta_work+0x0/0xd2=
d [mac80211]
>> [ =C2=A0919.860218] =C2=A0[<c1032217>] ? autoremove_wake_function+0x=
0/0x2f
>> [ =C2=A0919.860223] =C2=A0[<c102ef18>] ? worker_thread+0x0/0x204
>> [ =C2=A0919.860229] =C2=A0[<c1031fab>] kthread+0x63/0x68
>> [ =C2=A0919.860234] =C2=A0[<c1031f48>] ? kthread+0x0/0x68
>> [ =C2=A0919.860240] =C2=A0[<c1002f93>] kernel_thread_helper+0x7/0x10
>> [ =C2=A0919.860244] ---[ end trace 7a3a8d08c5a7bedf ]---
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>>
>
> --
> John W. Linville =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0might be all we have. =C2=A0Be ready.
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
