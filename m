From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
Date: Wed, 21 Jul 2010 13:45:13 -0700 (PDT)
Message-ID: <20100721.134513.200802525.davem@davemloft.net>
References: <20100721165055.GE13188@sequoia.sous-sol.org>
	<43F901BD926A4E43B106BF17856F0755F18462F6@orsmsx508.amr.corp.intel.com>
	<AANLkTi=Z_xSSaATcz-s8FoYcx6EYy+inH7cYZ_2W4AAs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chrisw@sous-sol.org, andy@greyhouse.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319Ab0GUUo5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 16:44:57 -0400
In-Reply-To: <AANLkTi=Z_xSSaATcz-s8FoYcx6EYy+inH7cYZ_2W4AAs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 21 Jul 2010 13:31:38 -0700

> On Wed, Jul 21, 2010 at 13:23, Rose, Gregory V <gregory.v.rose@intel.=
com> wrote:
>>>-----Original Message-----
>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org]
>>>On Behalf Of Chris Wright
>>>Sent: Wednesday, July 21, 2010 9:51 AM
>>>To: Andy Gospodarek
>>>Cc: netdev@vger.kernel.org; chrisw@sous-sol.org
>>>Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
>>>
>>>* Andy Gospodarek (andy@greyhouse.net) wrote:
>>>> Some ixgbe cards put an invalid VF device ID in the PCIe SR-IOV
>>>> capability. =A0The ixgbe driver is only valid for PFs or non SR-IO=
V
>>>> hardware. =A0It seems that the same problem could occur on igb har=
dware
>>>as
>>>> well, so if we discover we are trying to initialize a VF in
>>>ixbge_probe
>>>> or igb_probe, print an error and exit.
>>>>
>>>> Based on a patch for ixgbe from Chris Wright <chrisw@sous-sol.org>=
=2E
>>>>
>>>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>>>> Cc: Chris Wright <chrisw@sous-sol.org>
>>>
>>>Acked-by: Chris Wright <chrisw@sous-sol.org>
>>>
>>>Only seen this on ixgbe, but since the result there is a kernel pani=
c
>>>makes sense to be defensive.
>>>
>>>thanks,
>>>-chris
>>
>> Acked-by: Greg Rose <gregory.v.rose@intel.com>
>>
>> Looks good, thanks.
>>
>> - Greg
>>
>=20
> Dave, I do not plan on adding this patch to my queue, so feel free to
> take this patch after review.

Ok, will do.
