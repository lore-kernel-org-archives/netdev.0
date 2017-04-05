From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 05/13] ftgmac100: Cleanup speed/duplex tracking and
 fix duplex config
Date: Wed, 5 Apr 2017 16:58:03 +0200
Message-ID: <20170405145803.GG13449@lunn.ch>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
 <20170405022853.8238-6-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46679 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755883AbdDEO6G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 10:58:06 -0400
Content-Disposition: inline
In-Reply-To: <20170405022853.8238-6-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 12:28:45PM +1000, Benjamin Herrenschmidt wrote:
> Keep track of both the current speed and duplex settings
> instead of only speed and properly apply the duplex setting
> to the HW.
> 
> This reworks the adjust_link() function to also avoid trying
> to reconfigure the HW when there is no link and to display
> the link state to the user.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
