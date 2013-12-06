From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFCv2 0/6] net: phy: Ethernet PHY powerdown optimization
Date: Thu, 5 Dec 2013 16:16:32 -0800
Message-ID: <CAGVrzcYjcXfbYR7uyL1fAc2bdNhCUA9wAjZk4nsF2K0FRL2_pA@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1386171888-28190-1-git-send-email-sebastian.hesselbarth@gmail.com> <52A031EE.1040301@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A031EE.1040301@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/12/4 Mugunthan V N <mugunthanvnm@ti.com>:
> On Wednesday 04 December 2013 09:14 PM, Sebastian Hesselbarth wrote:
>> This is v2 of an RFC sent earlier [1] to reduce power consumption of network
>> PHYs with link that are either unused or the corresponding netdev is down.
>>
>> In contrast to RFCv1, this now integrates phy_suspend/phy_resume transparent
>> to the netdev drivers. Also, phy_suspend now only suspends the PHY if WOL is
>> disabled. Moreover, the phy state machine calls phy_suspend on entering
>> HALTED state.
>>
>> Again, a branch with RFCv2 applied to v3.13-rc2 can also be found at
>> https://github.com/shesselba/linux-dove.git topic/ethphy-power-rfc-v2
>>
>> [1] http://lwn.net/Articles/574426/
>>
>> Sebastian Hesselbarth (6):
>>   net: mv643xx_eth: properly start/stop phy device
>>   net: phy: marvell: provide genphy suspend/resume
>>   net: phy: provide phy_resume/phy_suspend helpers
>>   net: phy: resume/suspend PHYs on attach/detach
>>   net: phy: suspend unused PHYs on mdio_bus in late_initcall
>>   net: phy: suspend phydev when going to HALTED
>>
>>  drivers/net/ethernet/marvell/mv643xx_eth.c |    4 +++-
>>  drivers/net/phy/marvell.c                  |   22 ++++++++++++++++++++++
>>  drivers/net/phy/mdio_bus.c                 |   25 +++++++++++++++++++++++++
>>  drivers/net/phy/phy.c                      |    6 +++++-
>>  drivers/net/phy/phy_device.c               |   27 +++++++++++++++++++++++++++
>>  include/linux/phy.h                        |    2 ++
>>  6 files changed, 84 insertions(+), 2 deletions(-)
>>
>> ---
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
> Apart form Sergei's comment the patch series looks good to me.
>
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Looks good to me as well:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Sebastian!
-- 
Florian
