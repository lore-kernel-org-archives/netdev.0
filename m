From: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC platform
Date: Wed, 30 Dec 2015 09:03:11 -0600
Message-ID: <CAL_JsqKP0QsbeP-8c5XusTcFEsgNgu==ca+5Z57Wq6Yq9EHVzA@mail.gmail.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
 <20151229.155314.1522114236952280828.davem@davemloft.net> <3925713.yDzK1dvrIv@diego>
 <20151229.204847.578920480799799256.davem@davemloft.net> <CAMuHMdVEj6MGtUPYLmGCtMcLxKs4rLoh+if23_Bk1p=qwQM_Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
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
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMuHMdVEj6MGtUPYLmGCtMcLxKs4rLoh+if23_Bk1p=qwQM_Gg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 4:17 AM, Geert Uytterhoeven
<geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> wrote:
> Hi David,
>
> On Wed, Dec 30, 2015 at 2:48 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> w=
rote:
>> From: Heiko St=C3=BCbner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
>> Date: Tue, 29 Dec 2015 23:27:55 +0100
>>> Am Dienstag, 29. Dezember 2015, 15:53:14 schrieb David Miller:
>>>> You have to submit this series properly, the same problem happend =
twice
>>>> now.
>>>>
>>>> When you submit a series you should:
>>>>
>>>> 1) Make it clear which tree you expect these changes to be applied
>>>>    to.  Here it is completely ambiguous, do you want it to go into
>>>>    my networking tree or some other subsystem tree?
>>>>
>>>> 2) You MUST keep all parties informed about all patches for a seri=
es
>>>>    like this.  That means you cannot drop netdev from patch #4 as
>>>>    you did both times.  Doing this aggravates the situation for
>>>>    #1 even more, because if a patch is not CC:'d to netdev it does
>>>>    not enter patchwork.  And if it doesn't go into patchwork, I'm
>>>>    not looking at it.
>>>
>>> I guess that is some unfortunate result of git send-email combined =
with
>>> get_maintainer.pl . In general I also prefer to see the whole serie=
s, but have
>>> gotten such partial series from other maintainers as well in the pa=
st, so it
>>> seems to be depending on preferences somewhat.
>>>
>>> For the series at hand, the 4th patch is the devicetree addition, w=
hich the
>>> expected way is me picking it up, after you are comfortable with th=
e code-
>>> related changes.
>>
>> Why would it not be appropriate for a DT file change to go into my t=
ree
>> if it corresponds to functionality created by the rest of the patche=
s
>> in the series?
>
> Because the DT change is very likely to conflict with other DT change=
s.
> That's why typically all DT changes go in through the platform/archit=
ecture
> maintainer.

I assume you mean DTS changes only here. Send the DTS changes as a
separate series/patch as there is not inter-dependency (if there is,
there is a problem with the change) with DTS changes. I expect the
sub-arch maintainers to be the main reviewers of DTS files anyway. If
there is a binding doc change, then I'd prefer that to be merged with
the driver.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
