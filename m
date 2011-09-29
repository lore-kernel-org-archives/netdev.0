From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: about bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh
 (Apple) drivers
Date: Thu, 29 Sep 2011 02:12:37 -0700
Message-ID: <CAL3LdT7EUs8BQ7+kikzD9MbTC4e2sHUs=5b1jQsieo-OZhU38A@mail.gmail.com>
References: <20110928070439.GV31404@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>,
	Russell Nelson <nelson@crynwr.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48400 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab1I2JMj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 05:12:39 -0400
Received: by fxe4 with SMTP id 4so1504775fxe.19
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 02:12:38 -0700 (PDT)
In-Reply-To: <20110928070439.GV31404@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2011 at 00:04, Sascha Hauer <s.hauer@pengutronix.de> wr=
ote:
> Hi,
>
>> commit 8fb6b0908176704a3ea22005e8a9fa3ebf35b5be
>> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: =C2=A0 Mon May 16 01:39:01 2011 -0700
>>
>> =C2=A0 =C2=A0bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (A=
pple) drivers
>>
>> =C2=A0 =C2=A0Move the Apple drivers into driver/net/ethernet/apple/ =
and make the
>> =C2=A0 =C2=A0necessary Kconfig and Makefile changes.
>
> This commit moves drivers/net/cs89x0.[ch] to drivers/net/ethernet/app=
le/.
>
> This is wrong. The cs89x0 driver is a general ISA driver and is also
> used on some embedded boards. This patch should only move drivers/net=
/mac89x0.c
> which basically is a driver for the same device but used on Macintosh=
=2E
>
> I think it should go to drivers/net/ethernet/cirrus instead.
>
> Sascha
>

Thanks Sasha, I am looking into the past emails on this to see if
there was a suggested reason that in be where it is at.  I do agree
with you that it looks like it should be in
/drivers/net/ethernet/cirrus/, before making a patch to move it, I
want to double check all the previous emails I received to ensure that
there was a logic reason for placing it where it is.

--=20
Cheers,
Jeff
