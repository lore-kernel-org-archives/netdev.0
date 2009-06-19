From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch] usbnet cdc_subset: fix issues talking to PXA gadgets
Date: Fri, 19 Jun 2009 03:13:01 -0700
Message-ID: <200906190313.02050.david-b@pacbell.net>
References: <200906190011.28320.david-b@pacbell.net> <20090619.002403.98174871.davem@davemloft.net> <20090619.010756.193703794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, aric@sdgsystems.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.sbc.mail.gq1.yahoo.com ([67.195.15.61]:46309 "HELO
	smtp102.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752548AbZFSKUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 06:20:21 -0400
In-Reply-To: <20090619.010756.193703794.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 19 June 2009, David Miller wrote:
> David this doesn't even compile:

Sorry, my bad.  Fixed in the followup.


> =A0 CC [M] =A0drivers/net/usb/cdc_subset.o
> drivers/net/usb/cdc_subset.c:313:32: error: macro "USB_DEVICE_VER" re=
quires 4 arguments, but only 2 given
> drivers/net/usb/cdc_subset.c:313: error: 'USB_DEVICE_VER' undeclared =
here (not in a function)
>=20
> There is absolutely no excuse for this, really.

Sure there is:  sent it out too soon, before the compile test!
