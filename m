From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [patch 03/13] eeprom_93cx6: Add data direction control.
Date: Fri, 30 Apr 2010 13:12:13 +0200
Message-ID: <20100430131213.2429dd1e@hyperion.delvare>
References: <20100429231621.015936077@fluff.org.uk>
	<20100429231739.749602911@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tristram.ha@micrel.com,
	support@tincantools.com, Wolfram Sang <w.sang@pengutronix.de>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ben Dooks <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bamako.nerim.net ([62.4.17.28]:56863 "EHLO bamako.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933533Ab0D3Rpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:45:49 -0400
In-Reply-To: <20100429231739.749602911@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Fri, 30 Apr 2010 00:16:24 +0100, Ben Dooks wrote:
> Some devices need to know if the data is to be output or read, so add a
> data direction into the eeprom structure to tell the driver whether the
> data line should be driven.
> 
> The user in this case is the Micrel KS8851 which has a direction
> control for the EEPROM data line and thus needs to know whether
> to drive it (writing) or to tristate it for receiving.
> 
> Signed-off-by: Ben Dooks <ben@simtec.co.uk>
> Cc: Wolfram Sang <w.sang@pengutronix.de>
> Cc: Jean Delvare <khali@linux-fr.org>
> Cc: Linux Kernel <linux-kernel@vger.kernel.org>

I don't know anything about these driver and device, so don't expect
any input from me.

-- 
Jean Delvare
