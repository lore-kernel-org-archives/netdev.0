From: Gabor Juhos <juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 2/2] ath9k: Gather and report IRQ sync_cause errors.
Date: Tue, 17 Apr 2012 23:29:52 +0200
Message-ID: <4F8DE0D0.5000701@openwrt.org>
References: <1334250240-21038-1-git-send-email-greearb@candelatech.com> <1334250240-21038-2-git-send-email-greearb@candelatech.com> <4F8DDB9F.8030302@openwrt.org> <4F8DDCF1.1080304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F8DDCF1.1080304-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2012.04.17. 23:13 keltez=C3=A9ssel, Ben Greear =C3=ADrta:
> On 04/17/2012 02:07 PM, Gabor Juhos wrote:
>>> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>>>
>>> Report all defined sync_cause errors in debugfs
>>> to aid with debugging.
>>>
>>> Use a macro to print out the interrupts file contents
>>> to decrease code duplication.
>>
>> Now, that the patch is in wireless-testing, I have noticed a minor p=
roblem
>> with it.
>=20
> Thanks for the report.

Np.

> I'll fix this shortly.

Thanks,
Gabor

>=20
> Thanks,
> Ben
>=20
>>> +#ifdef CONFIG_ATH9K_DEBUGFS
>>> +void ath9k_debug_sync_cause(struct ath_common *common, u32 sync_ca=
use);
>>> +#else
>>> +static void ath9k_debug_sync_cause(struct ath_common *common, u32
>>> sync_cause) {}
>>
>> Due to a missing 'inline' keyword, this causes a bunch of warnings i=
f
>> CONFIG_ATH9K_DEBUGFS is not enabled:
>>
>>     CC [M]  drivers/net/wireless/ath/main.o
>>     CC [M]  drivers/net/wireless/ath/regd.o
>>     CC [M]  drivers/net/wireless/ath/hw.o
>>     CC [M]  drivers/net/wireless/ath/key.o
>>     LD [M]  drivers/net/wireless/ath/ath.o
>>     CC [M]  drivers/net/wireless/ath/ath9k/beacon.o
>>   drivers/net/wireless/ath/ath9k/hw.h:962: warning: =E2=80=98ath9k_d=
ebug_sync_cause=E2=80=99
>> defined but not used
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
