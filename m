From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 08/14] gianfar: Remove unused gfar_add_fcb()
 function parameter
Date: Tue, 16 Dec 2008 15:33:11 -0800 (PST)
Message-ID: <20081216.153311.168632282.davem@davemloft.net>
References: <1229469667-25002-7-git-send-email-afleming@freescale.com>
	<1229469667-25002-8-git-send-email-afleming@freescale.com>
	<1229469667-25002-9-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754527AbYLPXdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:33:09 -0500
In-Reply-To: <1229469667-25002-9-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:21:01 -0600

> - Also, use cacheable_memzero instead of memset for performance reasons.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied.

Although using platform specific interfaces like
cacheable_memzero() means this driver moves even further
from being compilable on other platforms.

We'd like at some point to have NOP OF and other bus
layer interfaces even for platforms without those busses
so that compilations of various drivers on those busses
can still be build tested even on other platforms.
