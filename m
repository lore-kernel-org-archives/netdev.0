From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 05/13] ftgmac100: Cleanup speed/duplex tracking and fix
 duplex config
Date: Mon, 03 Apr 2017 07:35:55 +1000
Message-ID: <1491168955.26047.22.camel@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
         <20170402033523.9482-6-benh@kernel.crashing.org>
         <20170402182848.GA5189@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:42780 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750953AbdDBVgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 17:36:09 -0400
In-Reply-To: <20170402182848.GA5189@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 20:28 +0200, Andrew Lunn wrote:

> Please consider using phy_print_status().

So in a subsequent (not yet posted) patch, I add Pause support. I
noticed that phy_print_status() doesn't distinguish between full
and partial (asym) pause support.

Is that intentional ?

Otherwise, I'll submit a latch later to update it along with the
patch that adds pause support.

Cheers,
Ben.
