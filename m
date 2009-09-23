From: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
	driver.
Date: Wed, 23 Sep 2009 10:23:59 +0300
Message-ID: <1ba2fa240909230023v17fe2b49v4981d464dba469ed@mail.gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253689036.4458.22.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253689036.4458.22.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 9:57 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Wed, 2009-09-23 at 02:38 +0300, Tomas Winkler wrote:
>
>> +config IWMC3200TOP
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "Intel Wireless MultiCom Top D=
river"
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on MMC && EXPERIMENTAL
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0select FW_LOADER
>> + =C2=A0 =C2=A0 ---help---
>> + =C2=A0 =C2=A0 =C2=A0 Intel Wireless MultiCom 3200 Top driver is re=
sponsible for
>> + =C2=A0 =C2=A0 =C2=A0 for firmware load and enabled coms enumeratio=
n
>
> This seems like the wrong approach to me.
>
> To me, it seems like you have a device that contains an internal bus =
and
> allows bus enumeration. Typically, we would surface that bus in the
> driver/device model and allow sub-drivers to bind to that by way of
> exposing the internal bus, like e.g. drivers/ssb/.

=46rom HW perspective your assumption is not exactly correct. All the
devices are visible on the SDIO bus but they are not operational
(probe won't succeed) until TOP download the firmware and kicks the
devices. From SW perspective to create another bus layer is an option.
I'm not sure if it's not more complicated one.

Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
