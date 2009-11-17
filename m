From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 01:02:41 -0800 (PST)
Message-ID: <20091117.010241.44239459.davem@davemloft.net>
References: <200911170830.nAH8UtrE010608@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751588AbZKQJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 04:02:24 -0500
In-Reply-To: <200911170830.nAH8UtrE010608@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 17 Nov 2009 00:30:55 -0800

> +	return BFA_ROUNDUP(sizeof(struct bfa_cee_attr), BFA_DMA_ALIGN_SZ);

There is never a reason to invent your own infrastructure.  We
have perfectly fine working ROUNDUP() et al. interfaces available
in the Linux kernel.

Please use them (see linux/kernel.h:DIV_ROUND_UP() and friends).

