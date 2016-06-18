From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: et131x: use phydev from struct
 net_device
Date: Fri, 17 Jun 2016 22:31:19 -0700 (PDT)
Message-ID: <20160617.223119.1805398906421884179.davem@davemloft.net>
References: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.einon@gmail.com, andrew@lunn.ch, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, f.fainelli@gmail.com, fw@strlen.de,
	wuninsu@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 17 Jun 2016 23:32:14 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
