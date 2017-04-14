From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next] net: phy: test the right variable in
 phy_write_mmd()
Date: Fri, 14 Apr 2017 21:14:24 +0200
Message-ID: <20170414191424.GA17758@lunn.ch>
References: <20170414191041.GA27478@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk+kernel@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58792 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755455AbdDNTOf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Apr 2017 15:14:35 -0400
Content-Disposition: inline
In-Reply-To: <20170414191041.GA27478@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 10:10:41PM +0300, Dan Carpenter wrote:
> This is a copy and paste buglet.  We meant to test for ->write_mmd but
> we test for ->read_mmd.
> 
> Fixes: 1ee6b9bc6206 ("net: phy: make phy_(read|write)_mmd() generic MMD accessors")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
