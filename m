From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mvneta: read MAC address from hardware when
 available
Date: Tue, 04 Jun 2013 17:24:17 -0700 (PDT)
Message-ID: <20130604.172417.1543681648182420899.davem@davemloft.net>
References: <1370357543-23332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net,
	gregory.clement@free-electrons.com, andrew@lunn.ch,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	linux-arm-kernel@lists.infradead.org,
	sergei.shtylyov@cogentembedded.com, joe@perches.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab3FEAYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:24:20 -0400
In-Reply-To: <1370357543-23332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue,  4 Jun 2013 16:52:23 +0200

> This patch improves the logic used by the mvneta driver to find a MAC
> address for a particular interface. Until now, it was only looking at
> the Device Tree, and if no address was found, was falling back to
> generating a random MAC address.
> 
> This patch adds the intermediate solution of reading the MAC address
> from the hardware registers, in case it has been set by the
> bootloader. So the order is now:
> 
>  1) MAC address from the Device Tree
>  2) MAC address from the hardware registers
>  3) Random MAC address
> 
> This requires moving the MAC address initialization a little bit later
> in the ->probe() code, because it now requires the hardware registers
> to be remapped.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied to net-next, thanks.
