From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: broadcom: bcm63xx: use phydev from
 struct net_device
Date: Mon, 19 Sep 2016 21:40:18 -0400 (EDT)
Message-ID: <20160919.214018.1924681039435420417.davem@davemloft.net>
References: <1474210747-19627-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, treding@nvidia.com,
        ivecera@redhat.com, xypron.glpk@gmx.de, simon@fire.lp0.eu,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474210747-19627-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 18 Sep 2016 16:59:06 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
