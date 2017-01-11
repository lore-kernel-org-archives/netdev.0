From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Wed, 11 Jan 2017 23:59:48 +0100
Message-ID: <20170111225948.GH13033@lunn.ch>
References: <587410EF.5090607@ti.com>
 <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
 <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "charles-antoine.couret@nexvision.fr"
        <charles-antoine.couret@nexvision.fr>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57828 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753835AbdAKW74 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 17:59:56 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> looping in Charles-Antoine (author of patch
> with commit id 6cfb3bcc)
> 
> Charles-Antoine,
> 
> Do you have the ID of Marvell PHY 88E1512?

I suspect that is the wrong question to ask.

The Marvell driver is being loaded, so it must be using on of the IDs
in the driver. There is no ID in the driver specifically for the
88E1512. It seems like the 88E1512 uses the 88E1510 ID.

So i think the correct question should be, how can we tell the 88E1512
from the 88E1510 if they have the same ID in register 3.

It appears that for the 88E1512, page 0 are the copper registers and
page 1 is the fibre registers. Maybe the 88E1512 has an ID in page 1
register 3? Maybe the 88E1510 does not have an ID in page 1 register
3?

	Andrew
