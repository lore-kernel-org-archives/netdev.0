From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: ax88796: use phydev from struct
 net_device
Date: Thu, 16 Jun 2016 17:07:29 -0700 (PDT)
Message-ID: <20160616.170729.1335036072029071941.davem@davemloft.net>
References: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466028769-27866-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 16 Jun 2016 00:12:48 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
