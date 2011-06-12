From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sun, 12 Jun 2011 14:36:32 +0200
Message-ID: <4DF4B2D0.80408@gmail.com>
References: <20110611200625.GB14582@kroah.com>	<1307829318-18246-1-git-send-email-marius@kotsbak.com>	<20110611.162711.907394751613071878.davem@davemloft.net> <20110611.162942.1706711069327005315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110611.162942.1706711069327005315.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12. juni 2011 01:29, David Miller wrote:
> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Date: Sat, 11 Jun 2011 16:27:11 -0700 (PDT)
>
>> From: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Sat, 11 Jun 2011 23:55:18 +0200
>>
>>> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
>>> It has also an ACM interface that previous patches associates with the "option"
>>> module. To access those interfaces, the modem must first be switched from modem
>>> mode using a tool like usb_modeswitch.
>>>
>>> As the proprietary protocol has been discovered by watching the MS Windows driver
>>> behavior, there might be errors in the protocol handling, but stable and fast
>>> connection has been established for hours with Norwegian operator NetCom that
>>> distributes this modem with their LTE/4G subscription.
>>>
>>> More and updated information about how to use this driver is available here:
>>>
>>> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
>>> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
>>>
>>> Signed-off-by: Marius B. Kotsbak <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
>> Applied, thanks.
> Actually, reverted.
>
> There's a typo in your Makefile patch, and because of this it
> won't even build the new driver.

Oh sorry, I did make on the actual kalmia.ko to avoid building all
modules, so I did not notice. Sending a fixed patch. Ben, thanks for
pointing out.

> People are so damn anxious to get this backported into stable
> and various distributions,

Japp, people keeps asking for a version that compiles with kernel 2.6.32
for the Ubuntu LTS...
>  yet this patch wasn't even tested
> properly.

We were compiling it out of the kernel tree until now.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
