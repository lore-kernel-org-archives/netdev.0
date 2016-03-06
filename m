From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: PHY hardware reset
Date: Sun, 6 Mar 2016 01:22:21 +0100
Message-ID: <20160306002221.GC1976@lunn.ch>
References: <56DB5924.3020206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50768 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbcCFAWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2016 19:22:24 -0500
Content-Disposition: inline
In-Reply-To: <56DB5924.3020206@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 06, 2016 at 01:09:40AM +0300, Sergei Shtylyov wrote:
> Hello.
> 
>    I have a need to de-assert the active-low PHY hardware reset
> signal (mapped to a GPIO) before the MDIO bus scansince it's left
> asserted by the bootloader (U-Boot).

Hi Sergei

There is a thread about power sequencing for USB devices going on at
the moment. You have a very similar issue. The solution should be
generic enough to apply to MDIO busses as well as USB busses.

Search for:

[PATCH 1/3] usb: core: add power sequence for USB devices

       Andrew
