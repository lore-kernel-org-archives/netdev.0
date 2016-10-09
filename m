From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v9 1/1] net: phy: Cleanup the Edge-Rate feature
 in Microsemi PHYs.
Date: Sun, 9 Oct 2016 22:06:29 +0200
Message-ID: <20161009200629.GI12033@lunn.ch>
References: <1475828904-13839-1-git-send-email-allan.nielsen@microsemi.com>
 <1475828904-13839-2-git-send-email-allan.nielsen@microsemi.com>
 <20161007202225.GC8266@lunn.ch>
 <20161009194534.GA20767@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41960 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751066AbcJIUGc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Oct 2016 16:06:32 -0400
Content-Disposition: inline
In-Reply-To: <20161009194534.GA20767@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Year... I was actually a bit confused about this... But assumed that you had
> some conventions about saving "input" configuration.

Nope.

Humm, actually, i messed up here and missed something. Sorry.

You should really do all the DT parsing in the probe function, or a
function it calls. We want the probe to return -EINVAL if the device
tree is invalid. Either you can program the magic value immediately,
if it will survive a reset, or save it in the private structure until
the init is called.

   Andrew
