From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]skge napi->poll() locking bug
Date: Sun, 23 Mar 2008 03:19:43 -0700 (PDT)
Message-ID: <20080323.031943.23771660.davem@davemloft.net>
References: <200803231020.10030.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: mitov@issp.bas.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755529AbYCWKTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:19:33 -0400
In-Reply-To: <200803231020.10030.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marin Mitov <mitov@issp.bas.bg>
Date: Sun, 23 Mar 2008 10:20:09 +0200

Please send networking things at least CC:'d to netdev
as many networking developers do not subscribe to
linux-kernel

> According to: Documentation/networking/netdevices.txt:
> 
> <cite>
> napi->poll:
> ..........
> 	Context: softirq
> 	         will be called with interrupts disabled by netconsole.
> </cite>
> 
> napi->poll() could be called either with interrupts enabled 
> (in softirq context) or disabled (by netconsole), so the irq flag
> should be preserved.
> 
> Inspired by Ingo's resent forcedeth patch :-)
> 
> Regards
> 
> Marin Mitov
> 
> Signed-off-by: Marin Mitov <mitov@issp.bas.bg>

Acked-by: David S. Miller <davem@davemloft.net>
