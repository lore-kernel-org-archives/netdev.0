From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 00/13] OF device tree handling of PHY drivers
Date: Mon, 4 May 2009 18:14:21 -0500
Message-ID: <20090504231421.GA27541@ld0162-tx32.am.freescale.net>
References: <20090425224458.32392.31296.stgit@localhost.localdomain> <20090427.025436.68188155.davem@davemloft.net> <fa686aa40904271017x726f92ffsbbc730770298766b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	afleming@freescale.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54257 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbZEDXOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 19:14:36 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n44NEMBr025799
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 16:14:33 -0700 (MST)
Received: from ld0162-tx32.am.freescale.net (ld0162-tx32.am.freescale.net [10.82.19.112])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n44NEM1B012426
	for <netdev@vger.kernel.org>; Mon, 4 May 2009 18:14:22 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <fa686aa40904271017x726f92ffsbbc730770298766b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 11:17:08AM -0600, Grant Likely wrote:
> Kumar,
> 
> David has pulled my phylib changes into his -next tree.  However, some
> of the driver changes have been compile tested only due to lack of
> hardware.  Who can I ask to test the changes to the following files?
> 
>  arch/powerpc/platforms/82xx/ep8248e.c     |    9 +-

Tested OK.

>  drivers/net/fs_enet/fs_enet-main.c        |   69 +--
>  drivers/net/fs_enet/mii-bitbang.c         |   29 +-

Tested OK on pq2fads.

>  drivers/net/fs_enet/mii-fec.c             |   26 +-

Tested on ep88xc.  No *new* problems. :-P

-Scott
