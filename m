From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path
Date: Tue, 26 Oct 2010 14:23:26 -0700 (PDT)
Message-ID: <20101026.142326.104071099.davem@davemloft.net>
References: <20101022085248.GA8571@ff.dom.local>
	<20101026.104257.245396217.davem@davemloft.net>
	<20101026212042.GA1888@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, eminak71@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, avorontsov@mvista.com,
	afleming@freescale.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58868
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756735Ab0JZVbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 17:31:03 -0400
In-Reply-To: <20101026212042.GA1888@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 26 Oct 2010 23:20:42 +0200

> IMHO, the NAPI state is unary only for gfargrp, and multiple ->poll()
> instances share a (unary) rx_recycle queue without proper locking.

Ok, I see it now, thank you.

For now I'll apply your patch, but long term I think we should just
eradicate the recycling code from the entire tree.
