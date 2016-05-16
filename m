From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/2] phy dp83867: Make rgmii parameters optional
Date: Mon, 16 May 2016 22:15:09 +0200
Message-ID: <20160516201509.GD3738@lunn.ch>
References: <1463424763-58807-1-git-send-email-agraf@suse.de>
 <1463424763-58807-2-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, Dan Murphy <dmurphy@ti.com>
To: Alexander Graf <agraf@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463424763-58807-2-git-send-email-agraf@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2016 at 08:52:43PM +0200, Alexander Graf wrote:
> If you compile without OF_MDIO support in an RGMII configuration, we fail
> to configure the dp83867 phy today by writing garbage into its configuration
> registers.
> 
> On the other hand if you do compile with OF_MDIO and the phy gets loaded via
> device tree, you have to have the properties set in the device tree, otherwise
> we fail to load the driver and don't even attach the generic phy driver to
> the interface anymore.
> 
> To make things slightly more consistent, make the rgmii configuration properties
> optional and allow a user to omit them in their device tree.

The binding document actually says they are required. It would be good
to make the binding documentation and the code consistent.

   Andrew
