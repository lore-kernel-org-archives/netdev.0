From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Regression: e100_phy_init() isolates even selected PHY,
	causes 10 seconds boot delay
Date: Thu, 29 Oct 2009 06:19:25 -0700
Message-ID: <9929d2390910290619j65be89f0nd8e00fa460b1723f@mail.gmail.com>
References: <4AC3C09B.3040203@gmx.net>
	 <20091029.060239.202729106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bernhard.kaindl@gmx.net, bruce.w.allan@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:34154 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbZJ2NTV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 09:19:21 -0400
Received: by pwj9 with SMTP id 9so38365pwj.21
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 06:19:26 -0700 (PDT)
In-Reply-To: <20091029.060239.202729106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 06:02, David Miller <davem@davemloft.net> wrote=
:
> From: Bernhard Kaindl <bernhard.kaindl@gmx.net>
> Date: Wed, 30 Sep 2009 22:33:31 +0200
>
>> The current e100.c:e100_phy_init() electrically isolates all
>> the PHYs (even the selected PHY -- for a short time!) from the MII.
>>
>> This happens only for a short duration before the isolation
>> of the selected PHY is reverted, but it's enough to cause a
>> major disturbance in the startup of our e100-based cards:
>>
>> On a number of Embedded/Industry Pentium boards which are in use,
>> the result is that the initial DHCP negotiation takes more
>> than 10 seconds to complete with 2.6.30 and .31, while it's
>> done in a fraction of a second with 2.6.29 and earlier
>> (kernels tested with no delay range from 2.6.23 to 2.6.29)
>>
>> That regression was introduced on March 31 in the by a patch
>> from Bruce which first appeared in 2.6.30-rc3:
>
> Bruce, can you give some feedback on this? =C2=A0I'd like to see this=
 issue
> move forward.
>
> The only reason I haven't applied Bernhard's patch is because I
> haven't seen any feedback from Intel. =C2=A0But I will apply it anywa=
ys if
> I don't see reasonable feedback soon.
>
> Thanks.

Bruce has been working on this and we currently have a patch in test.
We should have an updated patch submitted later today or tomorrow.

--=20
Cheers,
Jeff
