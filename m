From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: dsa: use cpu_switch instead of ds[0]
Date: Wed, 18 Jan 2017 16:50:11 -0500 (EST)
Message-ID: <20170118.165011.1105041451937157028.davem@davemloft.net>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
        <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 17 Jan 2017 20:41:39 -0500

> Now that the DSA Ethernet switches are true Linux devices, the CPU
> switch is not necessarily the first one. If its address is higher than
> the second switch on the same MDIO bus, its index will be 1, not 0.
> 
> Avoid any confusion by using dst->cpu_switch instead of dst->ds[0].
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
