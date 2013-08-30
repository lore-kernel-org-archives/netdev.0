From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Fri, 30 Aug 2013 20:56:15 +0200
Message-ID: <8761unxb1s.fsf@nemi.mork.no>
References: <1377171946-19133-1-git-send-email-bjorn@mork.no>
	<87d2ovxcrx.fsf@nemi.mork.no>
	<20130830.144118.1671225313340653567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130830.144118.1671225313340653567.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Fri, 30 Aug 2013 14:41:18 -0400 (EDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Fri, 30 Aug 2013 20:18:58 +0200
>
>> Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:
>>=20
>>> This module generates a common default address on init,
>>> using eth_random_addr. Set addr_assign_type to let
>>> userspace know the address is random unless it was
>>> overridden by the minidriver.
>>>
>>> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>>=20
>> David,
>>=20
>> I see that this patch is marked "Changes Requested" in patchworks:
>> http://patchwork.ozlabs.org/patch/269030/
>>=20
>> But I haven't seen any request for changes, only Olivers ack. And th=
at's
>> all patchworks has recorded as well. Did I miss something?
>
> Your v2 of this series is all marked as Under Review.
>
> You have to understand, wrt. your initial submission, when someone
> asks for changes in one of the patches in a series I mark the whole
> series as changes requested.
>
> This gives a second level of reminder that when one patch needs chang=
es
> I expect the entire series to be resubmitted.

Huh?  This patch was never part of any series.  There are no references
or numbering in it.  I sent it as a standalone patch because the fix wa=
s
different and not depending on the other addr_assign_type changes.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
