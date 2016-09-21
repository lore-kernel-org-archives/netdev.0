From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5
 SoCs
Date: Wed, 21 Sep 2016 19:03:53 +1000
Message-ID: <1474448633.2857.119.camel@kernel.crashing.org>
References: <20160920063007.24291-1-joel@jms.id.au>
         <20160920063007.24291-7-joel@jms.id.au>
         <1474373594.2857.62.camel@kernel.crashing.org>
         <20160920152940.GI22292@lunn.ch>
         <CACPK8Xde3COqQ8euhj3Ww5pPiAn4iXvMqJVpjKu3eGa1Pm=1GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Andrew Jeffery <andrew@aj.id.au>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joel Stanley <joel@jms.id.au>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACPK8Xde3COqQ8euhj3Ww5pPiAn4iXvMqJVpjKu3eGa1Pm=1GA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-09-21 at 11:32 +0930, Joel Stanley wrote:
> I had a look at the eval board schematic and it appears that the line
> has pull down resistors on it, explaining why the IRQ fires when it's
> configured to active low. Other machines re-use the pin pin as a GPIO.
> So yes, I will change this to a dt property in v2. That will mean
> dropping 4/7 "net/faraday: Avoid PHYSTS_CHG interrupt" as well.

What line is it out of the PHY ? The PHY IRQ ? If yes then it's meant
to be telling you to go look at the PHY registers for a link status
change, but only works if the PHY has also been configured
appropriately...

Mostly we ignore those things in Linux and just poll the PHY.

Cheers,
Ben.
