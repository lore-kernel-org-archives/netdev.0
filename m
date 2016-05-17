From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] phy dp83867: Make rgmii parameters optional
Date: Tue, 17 May 2016 14:22:24 -0400 (EDT)
Message-ID: <20160517.142224.1322153249705614542.davem@davemloft.net>
References: <1463424763-58807-1-git-send-email-agraf@suse.de>
	<1463424763-58807-2-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, dmurphy@ti.com, andrew@lunn.ch
To: agraf@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbcEQSW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:22:27 -0400
In-Reply-To: <1463424763-58807-2-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Graf <agraf@suse.de>
Date: Mon, 16 May 2016 20:52:43 +0200

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
> 
> Signed-off-by: Alexander Graf <agraf@suse.de>

Applied.
