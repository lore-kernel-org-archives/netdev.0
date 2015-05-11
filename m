From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: fec: add support of ethtool get_regs
Date: Mon, 11 May 2015 14:10:02 -0400 (EDT)
Message-ID: <20150511.141002.1931123025374616373.davem@davemloft.net>
References: <1431295302-11738-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, rmk+kernel@arm.linux.org.uk,
	Frank.Li@freescale.com, LW@KARO-electronics.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbbEKSKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 14:10:06 -0400
In-Reply-To: <1431295302-11738-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 11 May 2015 00:01:42 +0200

> This enables the ethtool's "-d" and "--register-dump"
> options for fec devices.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   78 +++++++++++++++++++++++++++++
>  1 files changed, 78 insertions(+), 0 deletions(-)
> 
> Changelog:
> v2: (thanks Russell King and David Miller for the feedback)
> - don't use memcpy_fromio to copy registers
> v3: (thanks David Miller for the feedback)
> - only copy defined registers
> - fix warning reported by checkpatch.pl

Applied, thanks Philippe.
