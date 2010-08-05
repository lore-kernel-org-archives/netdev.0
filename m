From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform  busses
Date: Thu, 05 Aug 2010 08:27:39 -0700
Message-ID: <87fwyt13mc.fsf@deeprootsystems.com>
References: <4C59E654.1090403@codeaurora.org>
	<AANLkTimkMy6_201XNGb41e7LivkvVHMkFZWVoA-7UmBo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm\@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm\@opensource.se" <damm@opensource.se>,
	"lethal\@linux-sh.org" <lethal@linux-sh.org>,
	"rjw\@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao\@gmail.com" <eric.y.miao@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimkMy6_201XNGb41e7LivkvVHMkFZWVoA-7UmBo@mail.gmail.com>
	(Magnus Damm's message of "Thu, 5 Aug 2010 11:32:16 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Magnus Damm <magnus.damm@gmail.com> writes:

> On Thu, Aug 5, 2010 at 7:14 AM, Patrick Pannuto <ppannuto@codeaurora.=
org> wrote:
>> Inspiration for this comes from:
>> http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html
>>
>> RFC: http://lkml.org/lkml/2010/8/3/496
>> Patch is unchanged from the RFC. Reviews seemed generally positive
>> and it seemed this was desired functionality.
>
> Thanks for your patch, it's really nice to see work done in this area=
!
> I'd like to see something like this merged in the not so distant
> future. At this point I'm not so concerned about the details, so I'll
> restrict myself to this:
>
>> /drivers/my_driver.c
>> =A0 =A0 =A0 =A0static struct platform_driver my_driver =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.driver =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =3D "my-dri=
ver",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.owner =A0=3D THIS_MO=
DULE,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.bus =A0 =A0=3D &my_b=
us_type,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0},
>> =A0 =A0 =A0 =A0};
>
> I would really prefer not to have the bus type in the here. I
> understand it's needed at this point, but I wonder if it's possible t=
o
> adjust the device<->driver matching for platform devices to allow any
> type of pseudo-platform bus_type.

I totally agree here.  Keeping the drivers ignorant of the bus (or SoC)
they are on will make them much more portable.

Kevin
