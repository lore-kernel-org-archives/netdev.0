From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: use cpu_switch instead of ds[0]
Date: Wed, 18 Jan 2017 12:35:46 -0800
Message-ID: <805115a6-3d4e-b968-62cb-eed9af49380f@gmail.com>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
 <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/17/2017 05:41 PM, Vivien Didelot wrote:
> Now that the DSA Ethernet switches are true Linux devices, the CPU
> switch is not necessarily the first one. If its address is higher than
> the second switch on the same MDIO bus, its index will be 1, not 0.
> 
> Avoid any confusion by using dst->cpu_switch instead of dst->ds[0].
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
