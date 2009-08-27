From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] sfc: Do not reinitialise XAUI serdes before it has
 completed reset
Date: Wed, 26 Aug 2009 18:04:04 -0700 (PDT)
Message-ID: <20090826.180404.24817359.davem@davemloft.net>
References: <1251310606.27345.11.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754501AbZH0BDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:03:51 -0400
In-Reply-To: <1251310606.27345.11.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:16:46 +0100

> falcon_reset_xaui() waits for XGXS reset to complete, but the XAUI
> serdes reset may take longer.  It needs to check both reset active
> bits.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
