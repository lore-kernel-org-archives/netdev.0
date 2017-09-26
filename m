From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/5] net: dsa: use slave device phydev
Date: Tue, 26 Sep 2017 16:54:09 -0700
Message-ID: <292b4fbf-36c6-e63b-58dc-942ca71cc704@gmail.com>
References: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
 <20170926211535.21273-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926211535.21273-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 02:15 PM, Vivien Didelot wrote:
> There is no need to store a phy_device in dsa_slave_priv since
> net_device already provides one. Simply s/p->phy/dev->phydev/.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
