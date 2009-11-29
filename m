From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] sfc: Replace MDIO spinlock with mutex
Date: Sat, 28 Nov 2009 23:59:13 -0800 (PST)
Message-ID: <20091128.235913.240637968.davem@davemloft.net>
References: <1259422484.3709.4.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752934AbZK2H7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 02:59:07 -0500
In-Reply-To: <1259422484.3709.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:34:44 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> We never use MDIO in atomic context, so we don't need to spin.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
