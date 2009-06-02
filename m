From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: =?KOI8-R?B?79TXxdQ6IFtQQVRDSCAxMC8xMF0gaWVlZTgwMjE1NDogYWRkIGF0ODZyZjIzMC8=?=
	=?KOI8-R?B?cmYyMzEgc3BpIGRyaXZlcg==?=
Date: Tue, 2 Jun 2009 12:29:55 +0400
Message-ID: <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	 <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com>
	 <20090601203348.GC7143@doriath.ww600.siemens.net>
	 <200906021010.49613.hs4233@mail.mn-solutions.de>
	 <1243930893.3192.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1243930893.3192.62.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/6/2, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>:
> Hi Holger,
>
>> > I thought about drivers/net as about ip (well, more or less)
>> > network drivers. We have drivers/atm or drivers/bluetooth (and
>> > bluetooth is 802.15.1...).
>>
>> I actually like that this is drivers/bluetooth and not
>> drivers/ieee802151. Would you consider drivers/zigbee instead of
>> drivers/ieee802154 ???
>
> I fully agree here.
>
> Please use "zigbee" instead of "ieee*" names since that can become messy
> and confusing. I know that in theory the IEEE part of ZigBee is more
> low-level radio and could be used by non-ZigBee devices, but that is not
> gonna happen anyway. Especially with Bluetooth Low Energy pushing into
> the turf of ZigBee. So please use proper names and not confuse people
> with IEEE numbers ;)

This gonna happen, as we are most probably going to implement 6lowpan
on top of our stack. 6lowpan is a way to encapsulate IPv6 frames into
IEEE 802.15.4 and has nothing in common with ZigBee. Moreover
ZigBee is a trademark with strict rules upon it's usage. Our lawyers are
currently investigating if it's possible to use this name in projects like
Linux kernel which are open-source, non-related to any project but
OTOH can be encapsulated in any commercial project.

IEEE 802.15.4 is a term like IEEE 802.11. We do have mac80211,
we have had (until recently) ieee80211 dir, so why bother?

For Bluetooth naming directories 'bluetooth' is logical, as 802.15.1
standard is a less known name, doesn't incorporate latest changes
from Bluetooth, etc.

-- 
With best wishes
Dmitry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
