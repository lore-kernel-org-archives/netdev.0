From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 0/9] atl1c: update hardware settings - v3
Date: Fri, 20 Apr 2012 10:34:13 +0000
Message-ID: <157393863283F442885425D2C454285623D5AA79@nasanexd02a.na.qualcomm.com>
References: <1334902584-15584-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334902584-15584-1-git-send-email-xiong@qca.qualcomm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

    Please ignore this patch set, we found some NICs sometimes may fail to get IP via DHCP, this issue doesn't 100% happen.
    So, after fixing it, we will re-send a new patch set.
    Any suggestion would be great appreciated. Thanks a lot !

-Xiong  

> -----Original Message-----
> From: Huang, Xiong
> Sent: Friday, April 20, 2012 14:16
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Cc: qca-linux-team; nic-devel; Huang, Xiong
> Subject: [PATCH 0/9] atl1c: update hardware settings - v3
> 
> This update contains a serial of patches, most of them are hardware settings
> related. register definitions are refined (or removed if
> meaningless) for each patch.
> 
> This is the third serial patches, after reviewed/applied the fourth serial will be
> out.
> 
> The patches have addressed all sparse and checkpatch warnings.
> 
> Following NICs are tested:
> AR8131/AR8132/AR8151A/AR8152A/AR8152B
> Test item includes:
> build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.
> 
> xiong (9):
>   atl1c: remove REG_PHY_STATUS
>   atl1c: refine phy-register read/write function
>   atl1c: remove PHY contrl in atl1c_reset_pcie
>   atl1c: refine SERDES-clock related code
>   atl1c: remove PHY polling from atl1c_open
>   atl1c: update PHY reset related routine
>   atl1c: remove PHY reset/init for link down event
>   atl1c: add function atl1c_power_saving
>   atl1c: refine start/enable code for MAC module
> 
>  drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    2 +-
>  drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |  422 ++++++++++++-----
>  drivers/net/ethernet/atheros/atl1c/atl1c_hw.h      |  499 +++++++++++++-------
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |  240 +++-------
>  4 files changed, 693 insertions(+), 470 deletions(-)
> 
> --
> 1.7.7
