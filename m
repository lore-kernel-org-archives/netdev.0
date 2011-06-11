From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 11 Jun 2011 02:25:08 +0200
Message-ID: <4DF2B5E4.8070303@gmail.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com> <20110610235557.GA23443@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110610235557.GA23443-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11. juni 2011 01:55, Greg KH wrote:
> On Sat, Jun 11, 2011 at 01:34:30AM +0200, Marius B. Kotsbak wrote:
>> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
>> It has also an ACM interface that previous patches associates with the "option"
>> module. To access those interfaces, the modem must first be switched from modem
>> mode using a tool like usb_modeswitch.
> Do we need to blacklist this device from the option driver?

It is already done, in commits:

80f9df3e0093ad9f1eeefd2ff7fd27daaa518d25
15b2f3204a5c878c32939094775fb7349f707263

>   We can do
> that easily then you don't need a usb_modeswitch change, right?

usb_modeswitch is for turning it into a modem (with network+modem
interface) instead of just a windows driver serving dongle.

It is a tricky story, and it also is a problem using usb_modeswitch
newer than 1.1.4:

https://bugs.launchpad.net/ubuntu/+source/usb-modeswitch/+bug/769816

>> As the proprietary protocol has been discovered by watching the MS Windows driver
>> behavior, there might be errors in the protocol handling, but stable and fast
>> connection has been established for hours with Norwegian operator NetCom that
>> distributes this modem with their LTE/4G subscription.
>>
>> More and updated information about how to use this driver is available here:
>>
>> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
>> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
>>
>> Signed-off-by: Marius B. Kotsbak <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> Very nice job, one minor comment nit:
>
>> +/*
>> + * USB network interface driver for Samsung Kalmia based LTE USB modem like the
>> + * Samsung GT-B3730 and GT-B3710.
>> + *
>> + * Copyright (C) 2011 Marius Bjoernstad Kotsbak
> Email address after your name?

Will add.

>> + *
>> + * Sponsored by Quicklink Video Distribution Services Ltd.
>> + *
>> + * Based on the cdc_eem module.
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
> Do you really mean "any later version"?
>

I have not considered it much.

>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
> These two paragraphs are not needed, and unless you want to track the
> FSF's office changes for the next 40+ years, I'd really suggest not
> putting it in there at all.
>

Same here, I have reused what I found in other modules. Do you have an
example of a module with the recommended header?

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
