From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 30/33] sfc: Treat probe as unsuccessful if it scheduled
 a reset
Date: Fri, 12 Dec 2008 22:08:27 -0800 (PST)
Message-ID: <20081212.220827.113319661.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212130011.GD10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMGIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:08:25 -0500
In-Reply-To: <20081212130011.GD10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 13:00:12 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> efx_pci_probe_main() can return success despite a reset being scheduled.
> Catch this and retry or abort probe depending on the reset type.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
