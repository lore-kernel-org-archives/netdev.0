From: "Dr. H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION GTM601 during RING indication
Date: Fri, 4 Oct 2013 08:22:37 +0200
Message-ID: <4893FFB3-2A82-4AD4-A6B6-20270798051F@goldelico.com>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com> <20131003.152907.2144013596237714581.davem@davemloft.net> <C7520082-95CC-4D4F-BCE4-96A7D6346DB3@goldelico.com> <20131003.160049.199880461500344692.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, marek.belisko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131003.160049.199880461500344692.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Am 03.10.2013 um 22:00 schrieb David Miller:

> From: "Dr. H. Nikolaus Schaller" <hns-xXXSsgcRVICgSpxsJD1C4w@public.gmane.org>
> Date: Thu, 3 Oct 2013 21:40:34 +0200
> 
>> I have made the bug observation from debug log that this bit is set in a response
>> each time the modem has a RING message. It might be specific to this modem
>> and firmware version, i.e. a firmware bug. But we have no means to verify or even
>> change it in the firmware.
>> 
>> I.e. the driver must handle it in a better way.
>> 
>> Because the notification is rejected by the driver, the driver will hang up and the
>> whole modem connection breaks down.
>> 
>> With this patch, the problem was never observed again in ~2 years.
>> 
>> I'd hope the maintainer of this driver can shed some light on it.
> 
> I think if you suspect the bit is set in response to RING messages
> then you should define a macro so that the number is not just magic,
> and put a descriptrive comment above the macro definition for that
> bit.

Good idea! I will resend the patch.

--- hns--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
