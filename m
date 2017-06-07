From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: Clear and enable MIB counters on
 imx51
Date: Wed, 07 Jun 2017 10:07:42 -0400 (EDT)
Message-ID: <20170607.100742.9158707718791478.davem@davemloft.net>
References: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikita.yoush@cogentembedded.com,
        fabio.estevam@nxp.com, cphealy@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdFGOHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 10:07:47 -0400
In-Reply-To: <1496800629-24910-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  7 Jun 2017 03:57:09 +0200

> Both the IMX51 and IMX53 datasheet indicates that the MIB counters
> should be cleared during setup. Otherwise random numbers are returned
> via ethtool -S.  Add a quirk and a function to do this.
> 
> Tested on an IMX51.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
