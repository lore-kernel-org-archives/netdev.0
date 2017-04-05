From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH 0/2] ARM: am335x-icev2: Add ethernet support
Date: Wed, 5 Apr 2017 11:35:20 +0300
Message-ID: <1d0a9c73-3e68-295c-3477-7c47e9decce6@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
 <178a255a-5e26-fe6f-8d9e-a7755f0b5fca@ti.com>
 <20170404160106.GR10760@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <grygorii.strashko@ti.com>,
        <nsekhar@ti.com>, <jsarha@ti.com>, <linux-omap@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404160106.GR10760@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/04/17 19:01, Tony Lindgren wrote:
> * Roger Quadros <rogerq@ti.com> [170330 05:37]:
>> Hi Tony & Dave,
>>
>> On 13/03/17 15:42, Roger Quadros wrote:
>>> Hi,
>>>
>>> This series adds ethernet support to am335x-icev2 board.
>>>
>>> The ethernet PHYs on the board need an explicit GPIO reset pulse
>>> to ensure they bootstrap to the correct mode. Without the
>>> GPIO reset they just don't work.
>>>
>>> cheers,
>>> -roger
>>
>> Any comments on this series. Patch 1 is at version 2.
> 
> I think you meant patch 2/3 is at version2. I've picked
> patches 2 and 3 for v4.12 into dt and defconfig branches.

Thanks Tony.

> 
> You may need to resend the davinci_mdio.c patch alone
> for Dave as he usually won't pick individual patches I
> think.

OK, I'll send that one separately.

cheers,
-roger

> 
> Regards,
> 
> Tony
> 
>>> Roger Quadros (2):
>>>   net: davinci_mdio: add GPIO reset logic
>>>   ARM: dts: am335x-icev2: Add CPSW ethernet0 and ethernet1
>>>
>>>  .../devicetree/bindings/net/davinci-mdio.txt       |   2 +
>>>  arch/arm/boot/dts/am335x-icev2.dts                 | 113 +++++++++++++++++++++
>>>  drivers/net/ethernet/ti/davinci_mdio.c             |  68 +++++++++++--
>>>  3 files changed, 175 insertions(+), 8 deletions(-)
>>>
>>
