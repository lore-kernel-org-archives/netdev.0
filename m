From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12] sfc: Clean up RX event handling
Date: Sun, 29 Nov 2009 00:01:28 -0800 (PST)
Message-ID: <20091129.000128.21210982.davem@davemloft.net>
References: <1259422589.3709.13.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751964AbZK2IBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:01:23 -0500
In-Reply-To: <1259422589.3709.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:36:29 +0000

> Add 'likely' hint to test of rx_checksum_enabled.
> Don't count IP fragments; the IP stack can do that.
> Do count non-matching multicast packets.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
