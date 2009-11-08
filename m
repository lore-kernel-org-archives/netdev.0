From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 2)
Date: Sun, 08 Nov 2009 00:43:51 -0800 (PST)
Message-ID: <20091108.004351.236432748.davem@davemloft.net>
References: <20091104225257.GB29537@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, Sandeep.Kumar@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752881AbZKHInZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:43:25 -0500
In-Reply-To: <20091104225257.GB29537@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 5 Nov 2009 01:52:57 +0300

> This patch fixes following warnings:
> 
> fsl_pq_mdio.c:112:38: warning: cast adds address space to expression (<asn:2>)
> fsl_pq_mdio.c:124:38: warning: cast adds address space to expression (<asn:2>)
> fsl_pq_mdio.c:133:38: warning: cast adds address space to expression (<asn:2>)
> fsl_pq_mdio.c:414:11: warning: cast adds address space to expression (<asn:2>)
> 
> Instead of adding __force all over the place, introduce convenient
> fsl_pq_mdio_get_regs() call that does the ugly casting just once.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
