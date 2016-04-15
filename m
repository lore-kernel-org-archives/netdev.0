From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/7] net: dsa: mv88e6xxx: drop switch id
Date: Fri, 15 Apr 2016 21:38:18 +0200
Message-ID: <20160415193818.GE18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460744750-13896-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 02:25:50PM -0400, Vivien Didelot wrote:
> We already have the product number and revision stored in the info
> structure and the switch private state.
> 
> It is not necessary to clutter the header file with shifted product
> number for devices that we don't even support yet. Remove them.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c |  1 -
>  drivers/net/dsa/mv88e6xxx.h | 34 ----------------------------------
>  2 files changed, 35 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index d40ac4d..7ec87df 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -3027,7 +3027,6 @@ found:
>  	ps->bus = bus;
>  	ps->sw_addr = sw_addr;
>  	ps->info = info;
> -	ps->id = id & 0xfff0;
>  	ps->rev = id & 0xf;
>  
>  	dev_info(&ps->bus->dev, "found switch %s, revision %u\n",
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 7e86cc6..fb81945 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -68,39 +68,6 @@
>  #define PORT_PCS_CTRL_UNFORCED		0x03
>  #define PORT_PAUSE_CTRL		0x02
>  #define PORT_SWITCH_ID		0x03
> -#define PORT_SWITCH_ID_PROD_NUM_MASK	0xfff0
> -#define PORT_SWITCH_ID_REV_MASK		0x000f
> -#define PORT_SWITCH_ID_6031	0x0310
> -#define PORT_SWITCH_ID_6035	0x0350
> -#define PORT_SWITCH_ID_6046	0x0480
> -#define PORT_SWITCH_ID_6061	0x0610
> -#define PORT_SWITCH_ID_6065	0x0650
> -#define PORT_SWITCH_ID_6085	0x04a0
> -#define PORT_SWITCH_ID_6092	0x0970
> -#define PORT_SWITCH_ID_6095	0x0950
> -#define PORT_SWITCH_ID_6096	0x0980
> -#define PORT_SWITCH_ID_6097	0x0990
> -#define PORT_SWITCH_ID_6108	0x1070
> -#define PORT_SWITCH_ID_6121	0x1040
> -#define PORT_SWITCH_ID_6122	0x1050
> -#define PORT_SWITCH_ID_6123	0x1210
> -#define PORT_SWITCH_ID_6131	0x1060
> -#define PORT_SWITCH_ID_6152	0x1a40
> -#define PORT_SWITCH_ID_6155	0x1a50
> -#define PORT_SWITCH_ID_6161	0x1610
> -#define PORT_SWITCH_ID_6165	0x1650
> -#define PORT_SWITCH_ID_6171	0x1710
> -#define PORT_SWITCH_ID_6172	0x1720
> -#define PORT_SWITCH_ID_6175	0x1750
> -#define PORT_SWITCH_ID_6176	0x1760
> -#define PORT_SWITCH_ID_6182	0x1a60
> -#define PORT_SWITCH_ID_6185	0x1a70
> -#define PORT_SWITCH_ID_6240	0x2400
> -#define PORT_SWITCH_ID_6320	0x1150
> -#define PORT_SWITCH_ID_6321	0x3100
> -#define PORT_SWITCH_ID_6350	0x3710
> -#define PORT_SWITCH_ID_6351	0x3750
> -#define PORT_SWITCH_ID_6352	0x3520

NACK

These numbers are not obvious. PORT_SWITCH_ID_6320 i can
understand. 0x1150 i have no idea what it is.

	    Andrwe
