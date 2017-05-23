From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHYs
Date: Tue, 23 May 2017 18:03:53 +0200
Message-ID: <20170523160353.GB21169@lunn.ch>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 03:53:18PM +0000, Bogdan Purcareata wrote:
> Complete the work started by the following patches
> 5f6c99e0 net: phy: fix a bug in get_phy_c45_ids
> da1da284 net/phy: tune get_phy_c45_ids to support more c45 phy
> 
> in order to properly get non-standard C45 10G PHY IDs (e.g. Cortina
> CS4340).

At a first look, this seems to be a hack to work around a broken phy.

Instead of this, can you use the ethernet-phy-id property in device
tree?

	Andrew
