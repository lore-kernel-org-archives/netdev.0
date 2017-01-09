From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Tue, 10 Jan 2017 00:55:34 +0100
Message-ID: <20170109235534.GH22820@lunn.ch>
References: <587410EF.5090607@ti.com>
 <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53624 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752716AbdAIXzg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 18:55:36 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But when kernel is reboot into u-boot, "mii read 0 0" shows
> 0x1000, ie. bit 11 is 0, and still the phy auto-nego times out.

O.K, not so simple then.

I suggest you dump all the registers, in both the good and bad state,
and see how they differ.

    Andrew
