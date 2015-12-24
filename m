From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] phy: micrel: Fix finding PHY properties in MAC
 node for KSZ9031.
Date: Wed, 23 Dec 2015 22:14:28 -0500 (EST)
Message-ID: <20151223.221428.772195396330906108.davem@davemloft.net>
References: <1450867349-9436-1-git-send-email-henri.roosen@ginzinger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch
To: henri.roosen@ginzinger.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450867349-9436-1-git-send-email-henri.roosen@ginzinger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henri Roosen <henri.roosen@ginzinger.com>
Date: Wed, 23 Dec 2015 11:42:29 +0100

> +	do {
> +		of_node = dev_walker->of_node;
> +		dev_walker = dev_walker->parent;
> +
> +	} while (!of_node && dev_walker);

Please remove the unnecessary empty line in this loop.

Thanks.
