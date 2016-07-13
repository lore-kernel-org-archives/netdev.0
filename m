From: =?UTF-8?B?TWljaGHFgg==?= Pecio <michal.pecio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v6 RESEND] r8152: Add support for setting pass through
 MAC address on RTL8153-AD
Date: Wed, 13 Jul 2016 08:23:58 +0200
Message-ID: <20160713082358.487082a4@sauron>
References: <1468285084-26557-1-git-send-email-mario_limonciello@dell.com>
 <20160711.194246.742914205682079488.davem@davemloft.net>
 <20160712090248.7b5633e5@sauron>
 <5a304b784fe747aea4de6b69fb12a767@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<anthony.wong-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: <Mario_Limonciello-DYMqY+WieiM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5a304b784fe747aea4de6b69fb12a767-uCoIPMzyhkttLtSlb8FIwwVY21JRvFwKV6yJEvX+wlw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> So in order to hit this hypothetical corner case today you would 
> need to be using a real world type-C device something such as a 
> Dell WD15 on another OEM's machine that has type-C and the exact
> same ACPI object name that does $BADSTUFF other than return a
> buffer.
Exactly what I meant.
 
> If that situation arises please alert me and I'll send a follow up
> patch that whitelists this to match DMI vendor of only Dell 
> systems.
I'm not sure if it's the most responsible way to approach this problem.
There were cases of laptops bricking (as in - they would never power on
ever again) just because Linux made some bad BIOS/ACPI calls. Also, see
the famous Samsung UEFI NVRAM fiasco or the recent pains with EFIVARS.

Regards,
MP
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
