From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] NET: qmi_wwan: add Telit LE920 support
Date: Tue, 29 Jan 2013 09:40:38 +0100
Message-ID: <CAGRyCJEThQaex9au5AbWT-hm1Vvj2jxiXuAfrgNTdTofqAYY3A@mail.gmail.com>
References: <1359387918-2791-1-git-send-email-dnlplm@gmail.com>
	<87k3qxnt07.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k3qxnt07.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

2013/1/28 Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>:
> Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> Add VID, PID and fixed interface for Telit LE920
>>
>> Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/usb/qmi_wwan.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
>> index 6a1ca50..e32f9a1 100644
>> --- a/drivers/net/usb/qmi_wwan.c
>> +++ b/drivers/net/usb/qmi_wwan.c
>> @@ -459,6 +459,7 @@ static const struct usb_device_id products[] =3D=
 {
>>       {QMI_FIXED_INTF(0x1199, 0x68a2, 19)},   /* Sierra Wireless MC7=
710 in QMI mode */
>>       {QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7=
700 */
>>       {QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},    /* Telekom Speedstick =
LTE II (Alcatel One Touch L100V LTE) */
>> +     {QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},    /* Telit LE920 */
>>
>>       /* 4. Gobi 1000 devices */
>>       {QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},    /* Acer Gobi Modem Dev=
ice */
>
> Thanks for adding this device. But the patch doesn't apply to the
> current "net" tree.  Care to rebase it?
>

Sure. Should I use the following git repository

git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/net-next.git

?

Thanks,
Daniele
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
