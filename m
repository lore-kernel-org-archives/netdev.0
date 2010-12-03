From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 05/17] sfc: Clear RXIN_SEL when
 soft-resetting QT2025C
Date: Fri, 03 Dec 2010 09:08:57 -0800 (PST)
Message-ID: <20101203.090857.189697705.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333597.3259.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752524Ab0LCRIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:30 -0500
In-Reply-To: <1291333597.3259.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:46:37 +0000

> When we enable PMA/PMD loopback this automatically sets RXIN_SEL
> (inverse polarity for RXIN).  We need to clear that bit during the
> soft-reset sequence, as it is not done automatically.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
