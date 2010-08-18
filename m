From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Aug 2010 17:41:57 -0700 (PDT)
Message-ID: <20100817.174157.226783923.davem@davemloft.net>
References: <201008110424.o7B4OanK018594@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752453Ab0HRAli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 20:41:38 -0400
In-Reply-To: <201008110424.o7B4OanK018594@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 10 Aug 2010 21:24:36 -0700

> +u32 bna_id;

This variable is never set by the driver.

It is always left at it's default value of zero and it is only
used to construct MBOX irq name strings and it is also assigned
to bnad->ident.id

I suspect it's completely useless, and if so please just delete
it.
