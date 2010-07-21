From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
Date: Wed, 21 Jul 2010 13:31:38 -0700
Message-ID: <AANLkTi=Z_xSSaATcz-s8FoYcx6EYy+inH7cYZ_2W4AAs@mail.gmail.com>
References: <1279730431-17156-1-git-send-email-andy@greyhouse.net>
	<20100721165055.GE13188@sequoia.sous-sol.org>
	<43F901BD926A4E43B106BF17856F0755F18462F6@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Wright <chrisw@sous-sol.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36622 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab0GUUbx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:31:53 -0400
Received: by gyg10 with SMTP id 10so7330gyg.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 13:31:42 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F18462F6@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 13:23, Rose, Gregory V <gregory.v.rose@intel.co=
m> wrote:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg]
>>On Behalf Of Chris Wright
>>Sent: Wednesday, July 21, 2010 9:51 AM
>>To: Andy Gospodarek
>>Cc: netdev@vger.kernel.org; chrisw@sous-sol.org
>>Subject: Re: [PATCH net-2.6] ixgbe/igb: catch invalid VF settings
>>
>>* Andy Gospodarek (andy@greyhouse.net) wrote:
>>> Some ixgbe cards put an invalid VF device ID in the PCIe SR-IOV
>>> capability. =C2=A0The ixgbe driver is only valid for PFs or non SR-=
IOV
>>> hardware. =C2=A0It seems that the same problem could occur on igb h=
ardware
>>as
>>> well, so if we discover we are trying to initialize a VF in
>>ixbge_probe
>>> or igb_probe, print an error and exit.
>>>
>>> Based on a patch for ixgbe from Chris Wright <chrisw@sous-sol.org>.
>>>
>>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>>> Cc: Chris Wright <chrisw@sous-sol.org>
>>
>>Acked-by: Chris Wright <chrisw@sous-sol.org>
>>
>>Only seen this on ixgbe, but since the result there is a kernel panic
>>makes sense to be defensive.
>>
>>thanks,
>>-chris
>
> Acked-by: Greg Rose <gregory.v.rose@intel.com>
>
> Looks good, thanks.
>
> - Greg
>

Dave, I do not plan on adding this patch to my queue, so feel free to
take this patch after review.

--=20
Cheers,
Jeff
