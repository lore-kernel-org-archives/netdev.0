From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] sfc: Work around unreliable legacy interrupt status
Date: Sat, 21 Mar 2009 19:09:47 -0700 (PDT)
Message-ID: <20090321.190947.16125988.davem@davemloft.net>
References: <1237591540.3217.6.camel@achroite>
	<1237591601.3217.8.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752831AbZCVCKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:10:00 -0400
In-Reply-To: <1237591601.3217.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 20 Mar 2009 23:26:41 +0000

> In rare cases, reading the legacy interrupt status register can
> acknowledge an event queue whose attention flag has not yet been set
> in the register.  Until we service this event queue it will not
> generate any more interrupts.  Therefore, as a secondary check, poll
> the next slot in each active event queue whose flag is not set.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
