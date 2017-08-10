From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 1/2] drivers: net: davinci_mdio: remove busy loop on
 wait user access
Date: Thu, 10 Aug 2017 16:40:53 +0200
Message-ID: <20170810144053.GE24790@lunn.ch>
References: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com
To: Max Uvarov <muvarov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59726 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752362AbdHJOk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 10:40:56 -0400
Content-Disposition: inline
In-Reply-To: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 10:47:46AM +0300, Max Uvarov wrote:
> Polling 14 mdio devices on single mdio bus eats 30% of 1Ghz cpu time
> due to busy loop in wait(). Add small delay to relax cpu.

Hi Max

Please include a cover note when you have multiple patches in a
series.

With 14 devices, it makes sense to swap to using PHY interrupts if you
can. That should prevent the PHY state machine polling the PHYs every
second.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
