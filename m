From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] net/freescale: do not export any functions from
 fsl_pq_mdio.c
Date: Thu, 30 Aug 2012 13:30:17 -0400 (EDT)
Message-ID: <20120830.133017.2210891252733188882.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2H3RaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:30:19 -0400
In-Reply-To: <1346263683-3664-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:07:57 -0500

> None of the functions in fsl_pq_mdio.c are used by any other source file,
> so there's no point in exporting them.  Merge the header file into the
> source file, make all the functions static, remove any EXPORT_SYMBOL
> statements, and delete any #include "fsl_pq_mdio.h" statements.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
