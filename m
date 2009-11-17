From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/s390 drivers: add missing 'const' attribute
Date: Tue, 17 Nov 2009 06:47:14 -0800 (PST)
Message-ID: <20091117.064714.233536802.davem@davemloft.net>
References: <20091117134815.GE5124@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: braunu@de.ibm.com, netdev@vger.kernel.org
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750905AbZKQOq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 09:46:57 -0500
In-Reply-To: <20091117134815.GE5124@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 17 Nov 2009 14:48:15 +0100

> Add missing 'const' attribute to avoid the following compile warnings:
> 
> drivers/s390/net/ctcm_main.c: In function 'ctcm_init':
> drivers/s390/net/ctcm_main.c:1864: warning: assignment from incompatible pointer type
> drivers/s390/net/lcs.c: In function 'lcs_init_module':
> drivers/s390/net/lcs.c:2468: warning: assignment from incompatible pointer type
> drivers/s390/net/claw.c: In function 'claw_init':
> drivers/s390/net/claw.c:3408: warning: assignment from incompatible pointer type
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied to net-next-2.6, thank you.
