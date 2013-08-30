From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Fri, 30 Aug 2013 15:14:00 -0400 (EDT)
Message-ID: <20130830.151400.1400969856580136990.davem@davemloft.net>
References: <87d2ovxcrx.fsf@nemi.mork.no>
	<20130830.144118.1671225313340653567.davem@davemloft.net>
	<8761unxb1s.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8761unxb1s.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Fri, 30 Aug 2013 20:56:15 +0200

> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
>> From: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> Date: Fri, 30 Aug 2013 20:18:58 +0200
>>
>>> Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:
>>>=20
>>>> This module generates a common default address on init,
>>>> using eth_random_addr. Set addr_assign_type to let
>>>> userspace know the address is random unless it was
>>>> overridden by the minidriver.
>>>>
>>>> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>>>=20
>>> David,
>>>=20
>>> I see that this patch is marked "Changes Requested" in patchworks:
>>> http://patchwork.ozlabs.org/patch/269030/
>>>=20
>>> But I haven't seen any request for changes, only Olivers ack. And t=
hat's
>>> all patchworks has recorded as well. Did I miss something?
>>
>> Your v2 of this series is all marked as Under Review.
>>
>> You have to understand, wrt. your initial submission, when someone
>> asks for changes in one of the patches in a series I mark the whole
>> series as changes requested.
>>
>> This gives a second level of reminder that when one patch needs chan=
ges
>> I expect the entire series to be resubmitted.
>=20
> Huh?  This patch was never part of any series.  There are no referenc=
es
> or numbering in it.  I sent it as a standalone patch because the fix =
was
> different and not depending on the other addr_assign_type changes.

I was hoping to get this fix, via the series.  When we have multiple in=
stances
of the same bug it makes no sense to just fix one, especially now that =
you're
done the work to do all of them already.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
