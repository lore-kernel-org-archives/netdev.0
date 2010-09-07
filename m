From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] tipc: Fix misleading error code when
 enabling Ethernet bearers
Date: Mon, 06 Sep 2010 18:13:30 -0700 (PDT)
Message-ID: <20100906.181330.35026535.davem@davemloft.net>
References: <1283538822-25718-1-git-send-email-paul.gortmaker@windriver.com>
	<1283538822-25718-4-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968Ab0IGBNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:13:13 -0400
In-Reply-To: <1283538822-25718-4-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri,  3 Sep 2010 14:33:42 -0400

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Cause TIPC to return EAGAIN if it is unable to enable a new Ethernet
> bearer because one or more recently disabled Ethernet bearers are
> temporarily consuming resources during shut down.  (The previous error
> code, EDQUOT, is now returned only if all available Ethernet bearer
> data structures are fully enabled at the time the request to enable an
> additional bearer is received.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
