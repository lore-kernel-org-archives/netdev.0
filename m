From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1] net: phy: micrel: add KSZ8795 ethernet switch
Date: Thu, 26 Jan 2017 19:12:07 +0100
Message-ID: <20170126181207.GF5656@lunn.ch>
References: <20170123075846.12888-1-sean.nyekjaer@prevas.dk>
 <20170123151219.GE10895@lunn.ch>
 <732c14ff-f0cf-67d5-bcf9-cbbf9a4391b3@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sean =?iso-8859-1?Q?Nyekj=E6r?= <sean.nyekjaer@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46800 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751767AbdAZSlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 13:41:09 -0500
Content-Disposition: inline
In-Reply-To: <732c14ff-f0cf-67d5-bcf9-cbbf9a4391b3@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I remove the word "Switch" from the commit message and phy name.
> The rest is okay?

Yes.

> What is generally being done when to phy's have the same id, micrel
> have done this many times...

It should not be a problem. When you write a switch driver for the
switch, it will be in device tree. Look at the Marvell Switches as an
example. Switches don't probe based on the ID in registers 2 and 3,
because switches often respond to many different addresses, or don't
have an ID in register 2 and 3.

So it should not matter if the switch and the PHYs embedded in the
switch have the same ID.

When do you plan to post your switch driver?

       Andrew
