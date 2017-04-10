From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/6] net: mvmdio: disable interrupt if resource size is
 too small
Date: Mon, 10 Apr 2017 21:29:07 +0200
Message-ID: <20170410192907.GD32277@lunn.ch>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
 <E1cxbEq-0006gR-Dy@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54058 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752086AbdDJT3L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 15:29:11 -0400
Content-Disposition: inline
In-Reply-To: <E1cxbEq-0006gR-Dy@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 04:28:20PM +0100, Russell King wrote:
> Disable the MDIO interrupt, falling back to polled mode, if the resource
> size does not allow us to access the interrupt registers.  All current
> DT bindings use a size of 0x84, which allows access, but verifying it is
> good practice.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
