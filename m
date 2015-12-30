From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC platform
Date: Wed, 30 Dec 2015 11:17:59 +0100
Message-ID: <CAMuHMdVEj6MGtUPYLmGCtMcLxKs4rLoh+if23_Bk1p=qwQM_Gg@mail.gmail.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
	<20151229.155314.1522114236952280828.davem@davemloft.net>
	<3925713.yDzK1dvrIv@diego>
	<20151229.204847.578920480799799256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, leozwang-hpIqsD4AKlcxg7vii5yOFA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151229.204847.578920480799799256.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Dec 30, 2015 at 2:48 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
> From: Heiko St=C3=BCbner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
> Date: Tue, 29 Dec 2015 23:27:55 +0100
>> Am Dienstag, 29. Dezember 2015, 15:53:14 schrieb David Miller:
>>> You have to submit this series properly, the same problem happend t=
wice
>>> now.
>>>
>>> When you submit a series you should:
>>>
>>> 1) Make it clear which tree you expect these changes to be applied
>>>    to.  Here it is completely ambiguous, do you want it to go into
>>>    my networking tree or some other subsystem tree?
>>>
>>> 2) You MUST keep all parties informed about all patches for a serie=
s
>>>    like this.  That means you cannot drop netdev from patch #4 as
>>>    you did both times.  Doing this aggravates the situation for
>>>    #1 even more, because if a patch is not CC:'d to netdev it does
>>>    not enter patchwork.  And if it doesn't go into patchwork, I'm
>>>    not looking at it.
>>
>> I guess that is some unfortunate result of git send-email combined w=
ith
>> get_maintainer.pl . In general I also prefer to see the whole series=
, but have
>> gotten such partial series from other maintainers as well in the pas=
t, so it
>> seems to be depending on preferences somewhat.
>>
>> For the series at hand, the 4th patch is the devicetree addition, wh=
ich the
>> expected way is me picking it up, after you are comfortable with the=
 code-
>> related changes.
>
> Why would it not be appropriate for a DT file change to go into my tr=
ee
> if it corresponds to functionality created by the rest of the patches
> in the series?

Because the DT change is very likely to conflict with other DT changes.
That's why typically all DT changes go in through the platform/architec=
ture
maintainer.

> It looks better to put it all together as a unit, via one series, wit=
h
> a merge commit containing your "[PATCH 0/N]" description in the commi=
t
> message.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
