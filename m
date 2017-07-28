From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: lan9303: Renamed indirect phy
 access functions
Date: Fri, 28 Jul 2017 10:03:29 -0700
Message-ID: <c8b12632-c78a-3dec-c5c0-a94f24d0775e@gmail.com>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-4-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728151157.28983-4-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2017 08:11 AM, Egil Hjelmeland wrote:
> Preparing for the following fix of MDIO phy access:
> 
> Renamed functions that access PHY 1 and 2 indirectly through PMI
> registers.
> 
>  lan9303_port_phy_reg_wait_for_completion() to
>  lan9303_indirect_phy_wait_for_completion()
> 
>  lan9303_port_phy_reg_read() to
>  lan9303_indirect_phy_read()
> 
>  lan9303_port_phy_reg_write() to
>  lan9303_indirect_phy_write()
> 
> Also changed "val" parameter of lan9303_indirect_phy_write() to u16,
> for clarity.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
