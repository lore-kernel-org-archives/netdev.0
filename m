From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: move netif_napi_add before binding
 interrupt
Date: Mon, 25 Aug 2014 17:32:20 -0700 (PDT)
Message-ID: <20140825.173220.130220460265473405.davem@davemloft.net>
References: <1408981440-19255-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org, talex5@gmail.com,
	ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756738AbaHZAcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:32:21 -0400
In-Reply-To: <1408981440-19255-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 25 Aug 2014 16:44:00 +0100

> Interrupt is enabled when bind_interdomain_evtchn_to_irqhandler returns.
> If there's interrupt pending interrupt handler is invoked.
> 
> NAPI needs to be initialised before binding interrupt otherwise the
> interrupt handler will try to scheduling a NAPI instance that is not
> initialised yet, resulting in kernel OOPS.
> 
> This fixes a regression introduced in ea2c5e13 ("xen-netback: move NAPI
> add/remove calls").
> 
> Ideally function calls to create kthreads should also be moved before
> binding but I intent to fix this regression with minimal changes and
> refactor the code with another patch.
> 
> Reported-by: Thomas Leonard <talex5@gmail.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>

Applied and queued up for -stable, thanks.
