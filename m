From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC/PATCH 01/13] net: wl12xx: sdio: id_tables should be __devinitconst
Date: Fri, 20 May 2011 18:14:55 +0200
Message-ID: <BANLkTimOyVHN--NXvje+zVOTxj6ghV+uOA@mail.gmail.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
 <1305321990-22041-2-git-send-email-balbi@ti.com> <BANLkTinsSuDj8vMYG-40aAw0UVwLDo2KDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felipe Balbi <balbi@ti.com>, Luciano Coelho <coelho@ti.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinsSuDj8vMYG-40aAw0UVwLDo2KDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/20 Ohad Ben-Cohen <ohad@wizery.com>:
> On Sat, May 14, 2011 at 12:26 AM, Felipe Balbi <balbi@ti.com> wrote:
>> That's only needed during init anyway, let's free
>> some space after we're done probing.
> sdio devices are dynamically created whenever the hw is plugged into
> the mmc slot by the user. that can happen anytime while the system is
> up, not only during init.
>> -static const struct sdio_device_id wl1271_devices[] =3D {
>> +static const struct sdio_device_id wl1271_devices[] __devinitconst =
=3D {
> it looks to me that sdio_match_device is going to be surprised if
> ->id_table won't be valid.
>
> i wouldn't do this, unless you have a good explanation otherwise.

devinit sections are not freed if device hotplug is enabled.

Best Regards,
Micha=B3 Miros=B3aw
