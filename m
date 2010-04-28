From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/17] sfc: Break NAPI processing after one ring-full
 of TX completions
Date: Wed, 28 Apr 2010 12:46:17 -0700 (PDT)
Message-ID: <20100428.124617.245419783.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272482982.2549.28.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756918Ab0D1TqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:46:12 -0400
In-Reply-To: <1272482982.2549.28.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:29:42 +0100

> Currently TX completions do not count towards the NAPI budget.  This
> means a continuous stream of TX completions can cause the polling
> function to loop indefinitely with scheduling disabled.  To avoid
> this, follow the common practice of reporting the budget spent after
> processing one ring-full of TX completions.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
