From: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] i2400m-sdio: select IWMC3200TOP in Kconfig
Date: Wed, 23 Sep 2009 08:36:41 +0300
Message-ID: <1ba2fa240909222236w5dc8f163p20e414073027e2e8@mail.gmail.com>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-3-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-4-git-send-email-tomas.winkler@intel.com>
	 <1253666644.2931.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253666644.2931.7.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2009 at 3:44 AM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> =
wrote:
> Hi Tomas,
>
>> i2400m-sdio requires iwmc3200top for its operation
>>
>> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> ---
>> =C2=A0drivers/net/wimax/i2400m/Kconfig | =C2=A0 =C2=A01 +
>> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/wimax/i2400m/Kconfig b/drivers/net/wimax/i2=
400m/Kconfig
>> index d623b3d..7368ad5 100644
>> --- a/drivers/net/wimax/i2400m/Kconfig
>> +++ b/drivers/net/wimax/i2400m/Kconfig
>> @@ -25,6 +25,7 @@ config WIMAX_I2400M_SDIO
>> =C2=A0 =C2=A0 =C2=A0 tristate "Intel Wireless WiMAX Connection 2400 =
over SDIO"
>> =C2=A0 =C2=A0 =C2=A0 depends on WIMAX && MMC
>> =C2=A0 =C2=A0 =C2=A0 select WIMAX_I2400M
>> + =C2=A0 =C2=A0 select IWMC3200TOP
>> =C2=A0 =C2=A0 =C2=A0 help
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Select if you have a device based on the=
 Intel WiMAX
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Connection 2400 over SDIO.
>
> this is not true actually. Since the WiMAX hardware in my laptop does=
n't
> require the top driver.
>
SDIO?

Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
