From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types
 (ISA/ISAPnP/EISA)
Date: Tue, 30 Apr 2013 15:33:44 -0400 (EDT)
Message-ID: <20130430.153344.707704312490940935.davem@davemloft.net>
References: <1367272013-2496-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932661Ab3D3Tdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:33:45 -0400
In-Reply-To: <1367272013-2496-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Mon, 29 Apr 2013 17:46:53 -0400

> The venerable 3c509 driver only sets its device parent in one case, the ISAPnP one.
> It does this with the SET_NETDEV_DEV function. It should register with the device
> hierarchy in two additional cases: standard (non-PnP) ISA and EISA.
> 
> - Currently they appear here:
> /sys/devices/virtual/net/eth0 (standard ISA)
> /sys/devices/virtual/net/eth1 (EISA)
> 
> - Rather, they should instead be here:
> /sys/devices/isa/3c509.0/net/eth0 (standard ISA)
> /sys/devices/pci0000:00/0000:00:07.0/00:04/net/eth1 (EISA)
> 
> Tested on ISA and EISA boards.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

Applied and queued up for -stable, thanks for being so persistent
about this fix :-)
