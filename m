From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] cdc_ether: allow vendor specific data interface if
 control interface is vendor specific
Date: Tue, 13 Dec 2011 14:39:08 +0400
Message-ID: <4EE72B4C.9060602@mvista.com>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no> <1323750784-32608-3-git-send-email-bjorn@mork.no> <1323752053.3837.17.camel@joe2Laptop> <87vcplcbj3.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87vcplcbj3.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 13-12-2011 8:59, Bj=C3=B8rn Mork wrote:

>> On Tue, 2011-12-13 at 05:33 +0100, Bjorn Mork wrote:
>>> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ethe=
r.c
>> []
>>> @@ -211,8 +211,12 @@ int usbnet_generic_cdc_bind(struct usbnet *dev=
, struct usb_interface *intf)
>> []
>>> -				dev_dbg(&intf->dev, "slave class %u\n",
>> []
>>> +				dev_dbg(&intf->dev, "xslave class %u\n",
>>
>> Why change the output from slave to xslave?
>
> That was unintentional.  Sorry.  Don't understand how checkpatch coul=
d
> have missed that :-)

    Don't understand what checkpatch.pl would have to do with that. :-)

WBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
