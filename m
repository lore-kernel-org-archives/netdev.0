From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] 3c59x: Fix call to mdio_sync() with the
 wrong argument
Date: Fri, 23 Jul 2010 13:05:38 -0700 (PDT)
Message-ID: <20100723.130538.229733396.davem@davemloft.net>
References: <1279844308.4883.365.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dktrkranz@debian.org,
	589989@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758203Ab0GWUFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 16:05:21 -0400
In-Reply-To: <1279844308.4883.365.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 23 Jul 2010 01:18:28 +0100

> commit a095cfc40ec7ebe63e9532383c5b5c2a27b14075
> "3c59x: Specify window explicitly for access to windowed registers"
> changed the first parameter to mdio_sync(), from a pointer to the
> register mapping, to a pointer to the vortex_private structure,
> and changed all but one of the call sites.  Fix that last one.
> 
> Reported-by: Luca Falavigna <dktrkranz@debian.org>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
