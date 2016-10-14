From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 14:06:24 +0200
Message-ID: <20161014120624.GG5822@lunn.ch>
References: <5800159B.3080708@codeaurora.org>
 <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45370 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753660AbcJNMG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 08:06:26 -0400
Content-Disposition: inline
In-Reply-To: <5800C3C7.60705@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 06:38:47AM -0500, Timur Tabi wrote:
> Andrew Lunn wrote:
> >Normally, a sleeping PHY does respond to MDIO. Otherwise, how do you
> >wake it?
> >
> >So i assume this phy has some other means to wake it. What is this
> >means?
> 
> I'm guessing that someone has to call phy_resume() before/during the
> call to mdiobus_register, but I don't see how that's possible.

Please can you tell us what PHY which is, and how it is put to sleep
and woken up.

If the PHY cannot be woken up using MDIO, then maybe you need to look
at the mdio bus reset call?

   Andrew
