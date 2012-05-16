From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp_pch: Add missing #include <linux/slab.h>
Date: Wed, 16 May 2012 14:58:58 -0400 (EDT)
Message-ID: <20120516.145858.1919303793301011436.davem@davemloft.net>
References: <1337169017-15835-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tshimizu818@gmail.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118Ab2EPTAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:00:10 -0400
In-Reply-To: <1337169017-15835-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 16 May 2012 13:50:17 +0200

> drivers/ptp/ptp_pch.c: In function 'pch_remove':
> drivers/ptp/ptp_pch.c:576:2: error: implicit declaration of function 'kfree' [-Werror=implicit-function-declaration]
> drivers/ptp/ptp_pch.c: In function 'pch_probe':
> drivers/ptp/ptp_pch.c:587:2: error: implicit declaration of function 'kzalloc' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied.
