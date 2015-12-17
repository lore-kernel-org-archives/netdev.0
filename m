From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] net: usb: cdc_ncm: Adding support for two new Dell devices
Date: Thu, 17 Dec 2015 13:47:36 +0100
Message-ID: <CAGRyCJFOq89v2u5n0yQw9eRSjvH3fntcpAbxrPMb498-7sOFYQ@mail.gmail.com>
References: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
	<1450285954.23793.15.camel@redhat.com>
	<87fuz15kqc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87fuz15kqc.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

2015-12-17 13:21 GMT+01:00 Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>:
> Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> On Wed, 2015-12-16 at 10:39 +0100, Daniele Palmas wrote:
>>> This patch series add support in the cdc_ncm driver for two devices
>>> based on the same platform, that are different only for carrier
>>> customization.
>>>
>>> The devices do not have ARP capabilities.
>>>
>>> Daniele Palmas (2):
>>>   net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadban=
d
>>>     Card
>>>   net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband
>>> Card
>>
>> Quite interesting; Google knows nothing about these devices that I c=
an
>> find.  What platform are these based on?
>
> There are a number of launchpad bugs reported for these devices.  Don=
't
> know why they chose that channel..  This one:
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1520147
> shows that it is an Intel/Infineon based design.
>
> BTW, DeWalt seems to own these device names :)
>

patches were passed first to Canonical for custom OS image testing.

413c:81ba is the HSPA+ variant of the family: however this does not
use ncm, but ecm, see
https://github.com/torvalds/linux/commit/0b88393cdf6b1322522849e61f7a33=
28f4fd3843

>
> Bj=C3=B8rn

Thanks,
Daniele
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
