From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mdio: mdio_if_info::mmds should not be __bitwise
Date: Tue, 18 Aug 2009 20:13:13 -0700 (PDT)
Message-ID: <20090818.201313.195124780.davem@davemloft.net>
References: <1250614778.2782.14.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59580
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbZHSDNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 23:13:02 -0400
In-Reply-To: <1250614778.2782.14.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 18 Aug 2009 17:59:38 +0100

> I misunderstood the meaning of __bitwise.  In practice it makes sparse
> warn about every use of mmds which is certainly not what we want.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This should be safe to include in 2.6.31 but it's hardly critical.

Applied to net-next-2.6, thanks.
