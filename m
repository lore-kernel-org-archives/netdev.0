From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2 -next] phy: remove an unneeded condition
Date: Tue, 12 Jan 2016 14:31:02 -0500 (EST)
Message-ID: <20160112.143102.310556950177714192.davem@davemloft.net>
References: <20160112093621.GF29804@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112093621.GF29804@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 12 Jan 2016 12:36:21 +0300

> It used to be that bus->irq was a pointer but after e7f4dc3536a4
> ('mdio: Move allocation of interrupts into core') it's an array inside
> the mdio struct, so it can never be NULL.  Let's remove the check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
