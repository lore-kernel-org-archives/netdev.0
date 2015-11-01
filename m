From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: use switchdev obj for VLAN add/del ops
Date: Sun, 01 Nov 2015 15:56:42 -0500 (EST)
Message-ID: <20151101.155642.1302328563488956087.davem@davemloft.net>
References: <1446399235-30668-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446399235-30668-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun,  1 Nov 2015 12:33:55 -0500

> Simplify DSA by pushing the switchdev objects for VLAN add and delete
> operations down to its drivers. Currently only mv88e6xxx is affected.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
> v2: make _mv88e6xxx_port_vlan_del static as spotted by the kbuild robot.

According to your previous submission this is targetted at net-next,
so that's where I applied it.

But please do not make me play guessing games like this in the future.
