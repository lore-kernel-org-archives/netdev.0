From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix inconsistent lock state
Date: Thu, 19 Aug 2010 00:28:34 -0700 (PDT)
Message-ID: <20100819.002834.216749563.davem@davemloft.net>
References: <1282114312-23500-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751447Ab0HSH2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:28:15 -0400
In-Reply-To: <1282114312-23500-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue, 17 Aug 2010 23:51:51 -0700

> Spin lock rds_ring->lock is used in poll routine, so other users should
> use spin_lock_bh(). While posting rx buffers from netxen_nic_attach,
> rds_ring->lock is not required, so cleaning it instead of fixing it by
> spin_lock_bh().
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
