From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: set slave MII bus PHY mask
Date: Sun, 25 Jan 2015 16:01:21 -0800 (PST)
Message-ID: <20150125.160121.1332719031463622112.davem@davemloft.net>
References: <1421799212-2028-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<1421799212-2028-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421799212-2028-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 20 Jan 2015 19:13:32 -0500

> When registering a mdio bus, Linux assumes than every port has a PHY and tries
> to scan it. If a switch port has no PHY registered, DSA will fail to register
> the slave MII bus. To fix this, set the slave MII bus PHY mask to the switch
> PHYs mask.
> 
> As an example, if we use a Marvell MV88E6352 (which is a 7-port switch with no
> registered PHYs for port 5 and port 6), with the following declared names:
> 
> 	static struct dsa_chip_data switch_cdata = {
> 		[...]
> 		.port_names[0] = "sw0",
> 		.port_names[1] = "sw1",
> 		.port_names[2] = "sw2",
> 		.port_names[3] = "sw3",
> 		.port_names[4] = "sw4",
> 		.port_names[5] = "cpu",
> 	};
> 
> DSA will fail to create the switch instance. With the PHY mask set for the
> slave MII bus, only the PHY for ports 0-4 will be scanned and the instance will
> be successfully created.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
