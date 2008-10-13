From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit
 compile failure
Date: Sun, 12 Oct 2008 23:09:39 -0700 (PDT)
Message-ID: <20081012.230939.240550430.davem@davemloft.net>
References: <20081013060615.GB29358@colo.lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	ron.mercer@qlogic.com, linux-ia64@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752632AbYJMGKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 02:10:04 -0400
In-Reply-To: <20081013060615.GB29358@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Mon, 13 Oct 2008 00:06:15 -0600

> QLGE driver only supports 4k, 8k, and 64k pages.
> Default page size on ia64 is 16k. Compile fails with:
> drivers/net/qlge/qlge.h:1118: error: 'TX_DESC_PER_OAL' undeclared here (not in a function)
> 
> Patch below makes the cause of the compile failure obvious.
> (Better would be to support 16k pages but I don't have the HW or interest.)
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

I would rather, at this point, give the qlge guys a day or two to
try and add support for other page sizes if that is possible.

If it isn't possible, I'd rather see a Kconfig guard, a compile
failure is really not acceptable.
