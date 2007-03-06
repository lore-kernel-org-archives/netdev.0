From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/19] user of the jiffies rounding code: e1000
Date: Tue, 06 Mar 2007 06:20:50 -0500
Message-ID: <45ED4E92.2060805@garzik.org>
References: <200703061041.l26AfmEP019740@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@linux.intel.com,
	auke-jan.h.kok@intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53356 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965859AbXCFLUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:20:52 -0500
In-Reply-To: <200703061041.l26AfmEP019740@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Arjan van de Ven <arjan@linux.intel.com>
> 
> Use the round_jiffies() function in e1000.
> 
> These timers all were of the "about once a second" or "about once every X
> seconds" variety and several showed up in the "what wakes the cpu up" profiles
> that the tickless patches provide.  Some timers are highly dynamic based on
> network load; but even on low activity systems they still show up so the
> rounding is done only in cases of low activity, allowing higher frequency
> timers in the high activity case.
> 
> The various hardware watchdogs are an obvious case; they run every 2 seconds
> but aren't otherwise specific of exactly when they need to run.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

applied 3-4 to #upstream (2.6.22)


