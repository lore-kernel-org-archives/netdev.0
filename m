From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sfc: Use correct macro to set event bitfield
Date: Tue, 14 Apr 2009 19:48:56 -0700 (PDT)
Message-ID: <20090414.194856.169034323.davem@davemloft.net>
References: <1239758992.3203.13.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756183AbZDOCtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 22:49:05 -0400
In-Reply-To: <1239758992.3203.13.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 15 Apr 2009 02:29:52 +0100

> falcon_sim_phy_event() used EFX_OWORD_FIELD, which operates on
> bitfields in 128-bit values, on an event, which is a 64-bit value.
> This should be harmless - these macros always use little-endian
> ordering, so it would read and write back the following 8 bytes
> unchanged - but it is obviously wrong.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.  And, I think this qualifies for net-2.6 so that's
where I put it.

Thanks!
