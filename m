From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: emaclite: Use platform resource table
Date: Tue, 4 Jun 2013 22:10:05 +0200
Message-ID: <201306042210.05844.arnd@arndb.de>
References: <6ece0a9ee777b987ca777a338cc146ed67897529.1370340196.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>,
	"David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:64045 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab3FDUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 16:10:17 -0400
In-Reply-To: <6ece0a9ee777b987ca777a338cc146ed67897529.1370340196.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 June 2013, Michal Simek wrote:
>   Read data directly from platform recource table
> and do not use of_irq_to_resource().
> Also use devm_request_and_ioremap() for probe
> functions simplification.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> ---
> Based on my discussion with Arnd
> "[PATCH] net: emaclite: include linux/of_irq.h"
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
