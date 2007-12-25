From: David Miller <davem@davemloft.net>
Subject: Re: [ETH]: Combine format_addr() with print_mac().
Date: Mon, 24 Dec 2007 21:28:37 -0800 (PST)
Message-ID: <20071224.212837.265942369.davem@davemloft.net>
References: <1198295882.6752.9.camel@dell>
	<1198306965.4895.5.camel@localhost>
	<1198455635.5491.4.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, anilgv@broadcom.com,
	michaelc@cs.wisc.edu, david.somayajulu@qlogic.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbXLYF2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 00:28:38 -0500
In-Reply-To: <1198455635.5491.4.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 23 Dec 2007 16:20:35 -0800

> Here's the revised patch:
> 
> [ETH]: Combine format_addr() with print_mac().
> 
> print_mac() used many most net drivers and format_addr() used by
> net-sysfs.c are very similar and they can be intergrated.
> 
> format_addr() is also identically redefined in the qla4xxx iscsi
> driver.
> 
> Export a new function sysfs_format_mac() to be used by net-sysfs,
> qla4xxx and others in the future.  Both print_mac() and
> sysfs_format_mac() call _format_mac_addr() to do the formatting.
> 
> Changed print_mac() to use unsigned char * to be consistent with
> net_device struct's dev_addr.  Added buffer length overrun checking
> as suggested by Joe Perches.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6.25, thanks Michael.
