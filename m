From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 27 Jan 2015 09:52:27 +0000
Message-ID: <54C75FDB.80805@linn.co.uk>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>	 <1422135432.18650.2.camel@perches.com> <54C620CB.3010500@linn.co.uk> <1422301185.18650.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422301185.18650.4.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 26/01/15 19:39, Joe Perches wrote:
> This header file is the public API for the driver.
> Should it not live under the 'include' directory?
> Several other drivers seem to follow that convention.
> It depends on how public is public.
>
> If it's _really_ public, it should be in uapi.
> If it's kinda public, then _maybe_ it should be
> in include/linux, but how likely is it another
> driver will use it?
>
>
It is intended for user space code that needs
to use the driver as it defines the netlink messages and
attributes that the driver understands. So I guess
uapi/linux would be the place for it.

Thanks,
Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
