From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Mon, 05 Feb 2007 18:10:26 -0800 (PST)
Message-ID: <20070205.181026.122835715.davem@davemloft.net>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965383AbXBFCK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 21:10:27 -0500
In-Reply-To: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Mon, 05 Feb 2007 16:31:11 -0800

> From: Andrew Morton <akpm@osdl.org>
> 
> "using smp_processor_id() in preemptible code"
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

We NAK'd this because every patch in the lockdep trace should
have preemption disabled because software interrupts ought
to be disabled in those code paths.

Someone needs to track down why this is really happening.
