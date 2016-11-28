From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/5] net: fix phydev reference leaks
Date: Sun, 27 Nov 2016 20:02:38 -0500 (EST)
Message-ID: <20161127.200238.2048371945400616113.davem@davemloft.net>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, madalin.bucur@nxp.com, timur@codeaurora.org,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Thu, 24 Nov 2016 19:21:26 +0100

> This series fixes a number of phydev reference leaks (and one of_node
> leak) due to failure to put the reference taken by of_phy_find_device().
> 
> Note that I did not try to fix drivers/net/phy/xilinx_gmii2rgmii.c which
> still leaks a reference.
> 
> Against net but should apply just as fine to net-next.
 ...
> v2: 
>  - use put_device() instead of phy_dev_free() to put the references
>    taken in net/dsa (patch 1/4).
>  - add four new patches fixing similar leaks

Series applied, thanks.
