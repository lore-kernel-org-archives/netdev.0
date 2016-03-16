From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v2 3/3] phy: mdio-thunder: Add driver for Cavium Thunder
 SoC MDIO buses.
Date: Thu, 17 Mar 2016 00:24:45 +0100
Message-ID: <56E9EB3D.6050406@suse.de>
References: <1457718791-6505-1-git-send-email-ddaney.cavm@gmail.com>
 <1457718791-6505-4-git-send-email-ddaney.cavm@gmail.com>
 <56E9E343.3080207@suse.de> <56E9E43A.6000304@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	netdev@vger.kernel.org, David Daney <david.daney@cavium.com>,
	linux-kernel@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	David Daney <ddaney.cavm@gmail.com>,
	Kumar Gala <galak@codeaurora.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40485 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966885AbcCPXYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 19:24:48 -0400
In-Reply-To: <56E9E43A.6000304@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.03.2016 um 23:54 schrieb David Daney:
> On 03/16/2016 03:50 PM, Andreas F=E4rber wrote:
>> Am 11.03.2016 um 18:53 schrieb David Daney:
>>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>>> index 40faec9..075a4cc 100644
>>> --- a/drivers/net/phy/Kconfig
>>> +++ b/drivers/net/phy/Kconfig
>>> @@ -196,6 +196,17 @@ config MDIO_OCTEON
>>>         buses. It is required by the Octeon and ThunderX ethernet d=
evice
>>>         drivers on some systems.
>>>
>>> +config MDIO_THUNDER
>>> +    tristate "Support for MDIO buses on on ThunderX SOCs"
>>
>> Double "on", spotted in next-20160316.
>>
>>> +    depends on 64BIT
>>> +    depends on PCI
>>> +    select MDIO_CAVIUM
>>> +    help
>>> +      This driver supports the MDIO interfaces found on Cavium
>>> +      ThunderX SoCs when the MDIO bus device appears on as a PCI
>>> +      device.
>>
>> While at it, this sentence sounds weird. Did you mean s/as/is/? Or i=
s
>> there another verb missing in there?
>=20
> Should be "... appears as a PCI device."
>=20
> davem already merged the patch, so this would have to be fixed as a
> follow-on patch.
>=20
> Since you found this, do you want to send the patch?

Done.

Cheers,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG N=FC=
rnberg)
