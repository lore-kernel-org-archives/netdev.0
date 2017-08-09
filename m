From: Romain Perier <romain.perier@collabora.com>
Subject: Re: [PATCH] net: stmmac: Use the right logging function in
 stmmac_mdio_register
Date: Wed, 9 Aug 2017 16:58:24 +0200
Message-ID: <9067382c-412f-343e-8273-4464366ba0f2@collabora.com>
References: <20170809144019.17975-1-romain.perier@collabora.com>
 <20170809145651.GK30723@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809145651.GK30723@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,


Le 09/08/2017 à 16:56, Andrew Lunn a écrit :
> On Wed, Aug 09, 2017 at 04:40:19PM +0200, Romain Perier wrote:
>> @@ -285,14 +286,14 @@ int stmmac_mdio_register(struct net_device *ndev)
>>  			irq_str = irq_num;
>>  			break;
>>  		}
>> -		netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
>> +		dev_info(dev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
>>  			    phydev->phy_id, addr, irq_str, phydev_name(phydev),
>>  			    act ? " active" : "");
> Hi Romain
>
> phy_attached_print() would be better.
>
>      Andrew
Ok, I did not know this function, good to know. I will investigate

Thanks,
Romain
