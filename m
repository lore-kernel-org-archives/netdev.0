From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/6] net: mvmdio: disable interrupts in driver failure
 path
Date: Mon, 10 Apr 2017 21:24:09 +0200
Message-ID: <20170410192409.GA32277@lunn.ch>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
 <E1cxbEa-0006g5-BY@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54036 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751619AbdDJTYP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 15:24:15 -0400
Content-Disposition: inline
In-Reply-To: <E1cxbEa-0006g5-BY@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 04:28:04PM +0100, Russell King wrote:
> When the mvmdio driver has an interrupt, it enables the "done" interrupt
> after requesting its interrupt handler.  However, probe failure results
> in the interrupt being left enabled.  Disable it on the failure path.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
