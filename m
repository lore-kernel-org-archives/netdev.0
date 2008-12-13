From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/33] sfc: Clean up MDIO flag setting
Date: Fri, 12 Dec 2008 21:49:07 -0800 (PST)
Message-ID: <20081212.214907.209841945.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125433.GR10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751992AbYLMFtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:49:05 -0500
In-Reply-To: <20081212125433.GR10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:54:34 +0000

> We often want to set or clear a flag in an MDIO register, but avoid
> writing if no change is required since this can have side-effects.
> Encapsulate this in a function, mdio_clause45_set_flag().
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
