From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 15:41:03 -0800
Message-ID: <CAGVrzcaJJBspF6o_0+kWHwh4hs7Q3YCknqZdFzS-ouyfBUecbQ@mail.gmail.com>
References: <1392334222-1089-1-git-send-email-f.fainelli@gmail.com>
 <20140213.183806.278183709549075615.davem@davemloft.net> <20140213.183914.1533527602267985176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Kevin Cernekee <cernekee@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35268 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbaBMXlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:41:44 -0500
In-Reply-To: <20140213.183914.1533527602267985176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-13 15:39 GMT-08:00 David Miller <davem@davemloft.net>:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 13 Feb 2014 18:38:06 -0500 (EST)
>
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Thu, 13 Feb 2014 15:30:12 -0800
>>
>>> This patchset adds support for the Broadcom GENET Gigabit Ethernet =
MAC
>>> controller. This controller is found on the Broadcom BCM7xxx Set To=
p Box
>>> System-on-a-chips.
>>>
>>> Changes since v3:
>>> - fixed Kconfig dependency on FIXED_PHY
>>>
>>> Changes since v2:
>>> - dropped the patch that adds an "internal" phy-mode
>>
>> Looks better, series applied, thanks.
>
> Actually, I have to revert, this breaks the allmodconfig build on x86=
_64:
>
> drivers/net/ethernet/broadcom/genet/bcmmii.c: In function =E2=80=98bc=
mgenet_mii_of_init=E2=80=99:
> drivers/net/ethernet/broadcom/genet/bcmmii.c:404:2: error: implicit d=
eclaration of function =E2=80=98of_get_next_child=E2=80=99 [-Werror=3Di=
mplicit-function-declaration]
> drivers/net/ethernet/broadcom/genet/bcmmii.c:404:10: warning: assignm=
ent makes pointer from integer without a cast [enabled by default]
> cc1: some warnings being treated as errors

Ok, would you agree in having a big fat "depends on OF" for now until
I can get an empty stub going with the DT people?
--=20
=46lorian
