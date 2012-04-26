From: "Luis R. Rodriguez" <mcgrof-kCJ/WVjk54vrZ44/DZwexQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2012-04-25
Date: Thu, 26 Apr 2012 04:46:34 -0700
Message-ID: <CAB=NE6Xqi42GgDRHg-oPuLgofXYGpBrLm-YPa+AfyQ+NhsK3ww@mail.gmail.com>
References: <20120425191418.GC16900@tuxdriver.com> <20120425.163926.2209040699696617525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120425.163926.2209040699696617525.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2012 at 1:39 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Wed, 25 Apr 2012 15:14:19 -0400
>
>> This is another batch of updates intended for 3.5...
> =C2=A0...
>> Please let me know if there are problems!
>
> There are:
>
> From 792545c7bc5d6b922d3778dc602e557d64c83551 Mon Sep 17 00:00:00 200=
1
> From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
> Date: Mon, 23 Apr 2012 19:55:48 -0700
> Subject: [PATCH 88/88] libertas: include sched.h on firmware.c
>
> Do not assume we have our subsystem including this for us,
> at least for older kernels this is not true. Lets just be
> explicit about this requirement for the usage of wake_up().
>
> Signed-off-by: Luis R. Rodriguez <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>
> This is bogus, wake_up() is defined in linux/wait.h, the whole
> point of the linux/sched.h split up is so that linux/sched.h
> includes could be removed and replaced with actual dependencies.
>
> Also, please don't accept any patches from Luis that add those
> #undef pr_fmt things to the atheros drivers.
>
> He tried to add it an ethernet driver, and I asked him to explain
> exactly why he's doing and that if it's appropriate then it's
> appropriate everywhere not just in a few specific drivers. =C2=A0He f=
ailed
> to respond to me, and therefore failed to explain the situation and
> address my concerned. =C2=A0And then I saw just today that he's submi=
tting
> the same patch to wireless drivers. =C2=A0That's not acceptable.

Sorry about that, I missed your reply, will dig it up and reply.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
