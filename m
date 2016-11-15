From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Wed, 16 Nov 2016 00:14:44 +0100
Message-ID: <46664e87-da42-ece8-43b9-094d2b24e1e4@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
 <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
 <0d1b4dee-11bb-3605-699c-ea417484cb68@gmx.de>
 <20161115215907.GF23231@lunn.ch>
 <86165d2b-f9d5-a380-9bb0-f77c12691eb6@gmx.de>
 <41c0c732-0935-1625-b88d-c084e5000a6c@gmail.com>
 <c645c726-dbe2-108d-c79a-d8db350a13b8@gmx.de>
 <20161115230317.GG23231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Florian Fainelli <f.fainelli@gmail.com>,
 gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, liodot@gmail.com,
 netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20161115230317.GG23231@lunn.ch>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 16.11.2016 00:03, Andrew Lunn wrote:
>> >>>>> +  			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
>> >>>>> +		     	         SLIC_PCR_AUTONEG_RST;
>> >>>>> +			slic_write(sdev, SLIC_REG_WPHY, val);
> 
>> Thats essentially what I meant by setting a flag in the irq handler. The mdio
>> function would have to check somehow if the irq has been fired (be it by means
>> of a flag or a completion that is set by the irq handler and checked by the 
>> mdio function). So I agree that it should work (if reading via the AP command
>> is actually possible).
> 
> It seems odd you have a nice simple way to do writes, but reads are
> very complex. There might be a simple read method hiding somewhere.
> 
>      Andrew
> 

I agree, it IS odd :). 
But concerning reading the phy this is all I can see in the original source code:

http://lxr.free-electrons.com/source/drivers/staging/slicoss/slichw.h#L516

I strongly suspect that "RPHY" stand for "read phy". The only one who may
know for sure if there is another/better way is Christopher Harrer. He is also on CC
but I am not sure if he actually follows this discussion.

Lino
