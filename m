From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH v2 3/3] phy: mdio-thunder: Add driver for Cavium Thunder
 SoC MDIO buses.
Date: Wed, 16 Mar 2016 15:54:50 -0700
Message-ID: <56E9E43A.6000304@caviumnetworks.com>
References: <1457718791-6505-1-git-send-email-ddaney.cavm@gmail.com> <1457718791-6505-4-git-send-email-ddaney.cavm@gmail.com> <56E9E343.3080207@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Daney <ddaney.cavm@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	<linux-kernel@vger.kernel.org>,
	David Daney <david.daney@cavium.com>
To: =?windows-1252?Q?Andreas_F=E4rber?= <afaerber@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E9E343.3080207@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/16/2016 03:50 PM, Andreas F=E4rber wrote:
> Hi,
>
> Am 11.03.2016 um 18:53 schrieb David Daney:
>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>> index 40faec9..075a4cc 100644
>> --- a/drivers/net/phy/Kconfig
>> +++ b/drivers/net/phy/Kconfig
>> @@ -196,6 +196,17 @@ config MDIO_OCTEON
>>   	  buses. It is required by the Octeon and ThunderX ethernet devic=
e
>>   	  drivers on some systems.
>>
>> +config MDIO_THUNDER
>> +	tristate "Support for MDIO buses on on ThunderX SOCs"
>
> Double "on", spotted in next-20160316.
>
>> +	depends on 64BIT
>> +	depends on PCI
>> +	select MDIO_CAVIUM
>> +	help
>> +	  This driver supports the MDIO interfaces found on Cavium
>> +	  ThunderX SoCs when the MDIO bus device appears on as a PCI
>> +	  device.
>
> While at it, this sentence sounds weird. Did you mean s/as/is/? Or is
> there another verb missing in there?

Should be "... appears as a PCI device."

davem already merged the patch, so this would have to be fixed as a=20
follow-on patch.

Since you found this, do you want to send the patch?

Thanks,
David Daney

>
> Regards,
> Andreas
>
>> +
>> +
>>   config MDIO_SUN4I
>>   	tristate "Allwinner sun4i MDIO interface support"
>>   	depends on ARCH_SUNXI
> [snip]
>
