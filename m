From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH net-next-2.6] can: add slcan driver for
 serial/USB-serial CAN adapters
Date: Mon, 29 Nov 2010 23:37:18 +0000
Message-ID: <20101129233718.45dee61d@lxorguk.ukuu.org.uk>
References: <4CF40D75.8030203@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:52977 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752532Ab0K2XiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 18:38:16 -0500
In-Reply-To: <4CF40D75.8030203@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Nov 2010 21:30:45 +0100
Oliver Hartkopp <socketcan@hartkopp.net> wrote:

> This patch adds support for serial/USB-serial CAN adapters implementing the
> LAWICEL ASCII protocol for CAN frame transport over serial lines.
> 
> The driver implements the SLCAN line discipline and is heavily based on the
> slip.c driver. Therefore the code style remains similar to slip.c to be able
> to apply changes of the SLIP driver to the SLCAN driver easily.

It looks almost identical. Would it not be better to either extract the
common code or put slip and slcann together as one, otherwise changes
will always get missed as they have to be done twice ?

How hard would it be to make the encap/decap pointers that can be
set to cleanly abstract both ?

Alan
