From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Tue, 15 Nov 2016 12:54:51 -0800
Message-ID: <4450caf4-e1cf-5187-1337-c46b81b08708@gmail.com>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
 <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, liodot@gmail.com, netdev@vger.kernel.org,
 davem@davemloft.net
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, Andrew Lunn <andrew@lunn.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
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

On 11/15/2016 12:46 PM, Lino Sanfilippo wrote:
>> Could this be pulled out into a standard PHY driver? All the SLIC
>> SLIC_PCR_ defines seems to be the same as those in mii.h. This could
>> be a standard PHY hidden behind a single register.
>>
>>    Andrew
> 
> You are right, the driver should really use the defines in mii.h. I will fix this in
>  a v2.
> 
> Concerning the use of the PHY API: What would be the advantage of using it? Note that the
>  phy is always internal and not interchangeable. Is not the interchangeability of PHYs
> the main reason for using this API?

Not reinventing the wheel primarily, while PHYLIB also solves the plug &
play aspect of external PHYs, it also solves the basic link management,
and consistent and reasonably well defined interface to user-space and
drivers (statistics reporting, link, auto-negotiation, EEE etc.).
-- 
Florian
