From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Thu, 15 Oct 2015 14:59:41 -0500
Message-ID: <562005AD.8020903@opensource.altera.com>
References: <561FF9E2.30102@opensource.altera.com> <56200687.9040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <david.daney@cavium.com>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56200687.9040903@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2015 03:03 PM, Florian Fainelli wrote:
> On 15/10/15 12:09, Dinh Nguyen wrote:
>> Hi,
>>
>> commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
>> the bus' parent." seems to have broken ethernet support for the SoCFPGA
>> platform which is using the stmmac ethernet driver.
> 
> It is not clear to me how this relates to what you are seeing yet.
> 
>>
>> It appears that during DHCP, it cannot get an IP address. This only
>> happens if ethernet was not used by the bootloader to tftp an kernel
>> image. If I use the bootloader to tftp an image then ethernet is working
>> fine. So I think the PHY is not getting enabled properly.
>>
>> If I revert this patch, then ethernet is back to working on the platform.
> 
> Is the Device Tree source for this platform available somewhere to look at?
> 

Yes, I'm using the DTS that is in the mainline:

arch/arm/boot/dts/socfpga.dtsi
arch/arm/boot/dts/socfpga_cyclone5.dtsi
arch/arm/boot/dts/socfpga_cyclone5_socdk.dts

Dinh
