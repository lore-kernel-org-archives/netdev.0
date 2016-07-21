From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net/faraday: Disallow using reversed MAC
 address from hardware
Date: Thu, 21 Jul 2016 16:01:09 +0200
Message-ID: <20160721140109.GM11309@lunn.ch>
References: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, David.Laight@ACULAB.COM
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47591 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbcGUOBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 10:01:15 -0400
Content-Disposition: inline
In-Reply-To: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:42:54AM +1000, Gavin Shan wrote:
> The initial MAC address is retrieved from hardware if it's not
> provided by device-tree. The reserved MAC address from hardware
> will be used if non-reserved MAC address is invalid. It will
> cause mismatched MAC address seen by hardware and software.
> 
> This disallows using the reserved hardware MAC address to avoid
> the mismatched MAC address seen by hardware and software.
> 
> Fixes: 113ce107afe9 ("net/faraday: Read MAC address from chip")
> Suggested-by: David Laight <David.Laight@ACULAB.COM>
> Suggested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

Too late now, since it has been accepted, but the subject line says
reversed, not reserved.

	  Andrew
