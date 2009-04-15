From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Match calls to netif_napi_add() and
 netif_napi_del()
Date: Tue, 14 Apr 2009 19:48:40 -0700 (PDT)
Message-ID: <20090414.194840.146819069.davem@davemloft.net>
References: <1239758250.3203.12.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751428AbZDOCst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 22:48:49 -0400
In-Reply-To: <1239758250.3203.12.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 15 Apr 2009 02:17:30 +0100

> sfc could call netif_napi_add() multiple times for the same
> napi_struct, corrupting the list of napi_structs for the associated
> device and leading to a busy-loop on device removal.  Move the call to
> netif_napi_add() and add a call to netif_napi_del() in the obvious
> places.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
