From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] MIPS: OCTEON: Rename Kconfig CAVIUM_OCTEON_REFERENCE_BOARD
 to CAVIUM_OCTEON_SOC
Date: Tue, 21 May 2013 15:07:23 -0700
Message-ID: <519BF01B.1010600@caviumnetworks.com>
References: <1369088378-13957-1-git-send-email-ddaney.cavm@gmail.com> <20130521220457.GF31836@blackmetal.musicnaut.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>, <linux-mips@linux-mips.org>,
	<ralf@linux-mips.org>, David Daney <david.daney@cavium.com>,
	<linux-ide@vger.kernel.org>, <linux-edac@vger.kernel.org>,
	<linux-i2c@vger.kernel.org>, <netdev@vger.kernel.org>,
	<spi-devel-general@lists.sourceforge.net>,
	<devel@driverdev.osuosl.org>, <linux-usb@vger.kernel.org>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20130521220457.GF31836@blackmetal.musicnaut.iki.fi>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/21/2013 03:04 PM, Aaro Koskinen wrote:
> Hi,
>
> What about OCTEON_WDT, should it be changed too:
>
>          tristate "Cavium OCTEON SOC family Watchdog Timer"
>          depends on CPU_CAVIUM_OCTEON
>
> On Mon, May 20, 2013 at 03:19:38PM -0700, David Daney wrote:
>>   config OCTEON_MGMT_ETHERNET
>>   	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
>> -	depends on  CPU_CAVIUM_OCTEON
>> +	depends on  CAVIUM_OCTEON_SOC
>
>>   config MDIO_OCTEON
>>   	tristate "Support for MDIO buses on Octeon SOCs"
>> -	depends on  CPU_CAVIUM_OCTEON
>> +	depends on  CAVIUM_OCTEON_SOC
>
>>   config USB_OCTEON_OHCI
>>   	bool "Octeon on-chip OHCI support"
>> -	depends on CPU_CAVIUM_OCTEON
>> +	depends on  CAVIUM_OCTEON_SOC
>
> Just a minor comment, here the extra whitespace after "depends on"
> could be eliminated.
>

Good point.  I will regenerate the patch to correct this.

Thanks,
David Daney



