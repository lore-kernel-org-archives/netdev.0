From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mv643xx_eth: Fetch the phy connection type from DT
Date: Wed, 26 Oct 2016 11:05:13 -0700
Message-ID: <de64deed-c2c3-ad20-b141-961c3d655f53@gmail.com>
References: <20161026174702.GB24717@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34358 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932993AbcJZSFQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:05:16 -0400
In-Reply-To: <20161026174702.GB24717@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2016 10:47 AM, Jason Gunthorpe wrote:
> The MAC is capable of RGMII mode and that is probably a more typical
> connection type than GMII today (eg it is used by Marvell Reference
> designs for several SOCs). Let DT users specify the standard
> 
>    phy-connection-type = "rgmii-id";
> 
> On a phy node.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Took a little while to understand the re-ordering of SET_NETDEV_DEV() to
come earlier was necessary to access mp->dev->dev.parent.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
