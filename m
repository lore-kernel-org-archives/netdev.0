From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: Fetch the phy connection type from DT
Date: Sat, 29 Oct 2016 15:11:47 -0400 (EDT)
Message-ID: <20161029.151147.2115675186525570052.davem@davemloft.net>
References: <20161026174702.GB24717@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, devicetree@vger.kernel.org,
        netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752319AbcJ2TLt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:11:49 -0400
In-Reply-To: <20161026174702.GB24717@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Wed, 26 Oct 2016 11:47:02 -0600

> The MAC is capable of RGMII mode and that is probably a more typical
> connection type than GMII today (eg it is used by Marvell Reference
> designs for several SOCs). Let DT users specify the standard
> 
>    phy-connection-type = "rgmii-id";
> 
> On a phy node.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Applied.
