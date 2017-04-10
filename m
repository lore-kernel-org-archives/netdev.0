From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/6] net: mvmdio: fix interrupt disable in remove path
Date: Mon, 10 Apr 2017 21:25:01 +0200
Message-ID: <20170410192501.GB32277@lunn.ch>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
 <E1cxbEf-0006gC-TV@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54042 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750989AbdDJTZI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 15:25:08 -0400
Content-Disposition: inline
In-Reply-To: <E1cxbEf-0006gC-TV@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 04:28:09PM +0100, Russell King wrote:
> The pre-existing write to disable interrupts on the remove path happens
> whether we have an interrupt or not.  While this may seem to be a good
> idea, this driver is re-used in many different implementations, some
> where the binding only specifies four bytes of register space.  This
> access causes us to access registers outside of the binding.
> 
> Make it conditional on the interrupt being present, which is the same
> condition used when enabling the interrupt in the first place.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
