From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2 v4] MPC52xx FEC: be more conservative when setting
	MII_SPEED register
Date: Fri, 17 Jul 2009 12:31:33 -0600
Message-ID: <fa686aa40907171131u79bf4bcdi66ad516c83919c99@mail.gmail.com>
References: <1247833628-15952-2-git-send-email-wd@denx.de>
	<1247835545-18650-1-git-send-email-wd@denx.de> <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.com>
	<20090717175138.97CB2832E416@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:42235 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbZGQSby convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 14:31:54 -0400
Received: by yxe14 with SMTP id 14so1785578yxe.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 11:31:53 -0700 (PDT)
In-Reply-To: <20090717175138.97CB2832E416@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 11:51 AM, Wolfgang Denk<wd@denx.de> wrote:
> Dear Grant Likely,
>
> In message <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.c=
om> you wrote:
>>
>> > =A0drivers/net/fec_mpc52xx.c =A0 =A0 | =A0 25 ++++++++++++++++++++=
++---
>> > =A0drivers/net/fec_mpc52xx_phy.c | =A0 23 ++++++++++++++++++++---
>>
>> Blech. =A0now this block of duplicated code I don't like. =A0This is=
 all
>> one device, so surely the mdio speed can be calculated once and used
>> for both drivers.... let me think about this for a bit. =A0'course t=
his
>> problem is all rolled up in the nastiness of having two drivers
>> working on the same device. =A0I suspect is was a mistake to split u=
p
>> all the powerpc ethernet drivers into separate of_platform drivers.
>
> If you like, I can re-introduce the mpc5xxx_get_mii_speed() I unrolle=
d
> upon your request (with or without re-using it for the MPC512x case).

No, there's a deeper issues here.  I'm bothered that the mac driver is
impacting the mdio driver.  I'd like to find a way for this whole
thing to be handled cleaner, and not have two different drivers
calculate it.

g.

>
>
> Best regards,
>
> Wolfgang Denk
>
> --
> DENX Software Engineering GmbH, =A0 =A0 MD: Wolfgang Denk & Detlev Zu=
ndel
> HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
> Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
> What is mind? =A0No matter. =A0What is matter? =A0Never mind.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0-- Thomas Hewitt Key, 1799-1875
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
