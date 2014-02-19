From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] of_mdio: fix phy interrupt passing
Date: Wed, 19 Feb 2014 17:27:39 +0400
Message-ID: <5304B14B.2070402@cogentembedded.com>
References: <1392725818-558-1-git-send-email-ben.dooks@codethink.co.uk>	<20140218161551.44A52C40517@trevor.secretlab.ca> <20140218.181317.1712776234149210938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@lists.codethink.co.uk,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>, grant.likely@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140218.181317.1712776234149210938.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 19-02-2014 3:13, David Miller wrote:

>>> The of_mdiobus_register_phy() is not setting phy->irq thus causing
>>> some drivers to incorrectly assume that the PHY does not have an
>>> IRQ associated with it. Not only do some drivers report no IRQ
>>> they do not install an interrupt handler for the PHY.

>>> Simplify the code setting irq and set the phy->irq at the same
>>> time so that we cover the following issues, which should cover
>>> all the cases the code will find:

>>> - Set phy->irq if node has irq property and mdio->irq is NULL
>>> - Set phy->irq if node has no irq and mdio->irq is not NULL
>>> - Leave phy->irq as PHY_POLL default if none of the above

>>> This fixes the issue:
>>>   net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI

>>> to the correct:
>>>   net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI

>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

>> Looks okay to me

>> Reviewed-by: Grant Likely <grant.likely@linaro.org>

> Applied, thanks.

    So, you decided to ignore my comment about unneeded *else* branch?

WBR, Sergei
