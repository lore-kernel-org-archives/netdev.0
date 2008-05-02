From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add a WARN_ON_ONCE() to the transmit timeout
 function
Date: Fri, 02 May 2008 16:21:18 -0700 (PDT)
Message-ID: <20080502.162118.113930840.davem@davemloft.net>
References: <20080501133424.678be79a@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937453AbYEBXVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:21:18 -0400
In-Reply-To: <20080501133424.678be79a@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Thu, 1 May 2008 13:34:24 -0700

> WARN_ON_ONCE() gives a stack trace including the full module list.
> Having this in the kernel dump for the timeout case in the
> generic netdev watchdog will help us see quicker which driver
> is involved. It also allows us to collect statistics 
> and patterns in terms of which drivers have this event occuring.
> 
> Suggested by Andrew Morton
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Looks good, applied.
