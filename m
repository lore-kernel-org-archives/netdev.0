From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 09/72] smc: Move the SMC drivers
Date: Sat, 25 Jun 2011 16:30:31 +0200
Message-ID: <201106251630.31152.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Pitre <nico@fluxnic.net>,
	Donald Becker <becker@scyld.com>, Erik Stahlman <erik@vt.edu>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:60475 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab1FYOaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:30:46 -0400
In-Reply-To: <1309010363-22750-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> Moves the SMC drivers into drivers/net/ethernet/smc/ and the
> necessary Kconfig and Makefile changes.  Also did some cleanup
> of NET_VENDOR_SMC Kconfig tag for the 8390 based drivers.
> 
> CC: Nicolas Pitre <nico@fluxnic.net>
> CC: Donald Becker <becker@scyld.com>
> CC: Erik Stahlman <erik@vt.edu>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ...
> drivers/net/{ => ethernet/smc}/epic100.c |    0
> drivers/net/{ => ethernet/smc}/smc9194.c |    0
> drivers/net/{ => ethernet/smc}/smc9194.h |    0
> drivers/net/{ => ethernet/smc}/smc91x.c  |    0
> drivers/net/{ => ethernet/smc}/smc91x.h  |    0

Isn't SMC (standard microsystems corporation) the company now known
as SMSC?

The comments in smc91x.c at least hint that this should be in the
same directory as the other smsc drivers.

	Arnd
