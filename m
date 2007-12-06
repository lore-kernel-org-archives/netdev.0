From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix br_fdb_fini() section mismatch
Date: Wed, 05 Dec 2007 21:33:07 -0800 (PST)
Message-ID: <20071205.213307.03574092.davem@davemloft.net>
References: <20071206052658.GD30235@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbXLFFdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:33:08 -0500
In-Reply-To: <20071206052658.GD30235@prithivi.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@gnumonks.org>
Date: Thu, 6 Dec 2007 10:56:58 +0530

> When compiling a kernel (current linus git or 2.6.24-rc4) with built-in
> CONFIG_BRIDGE, I get the following error:
> 
>   LD      .tmp_vmlinux1
> `br_fdb_fini' referenced in section `.init.text' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
> make: *** [.tmp_vmlinux1] Error 1
> 
> This patch fixes it.
> 
> Signed-off-by: Harald Welte <laforge@gnumonks.org>

Thanks, I already have this in my net-2.6.25 tree and will propagate
it to 2.6.24-rcX as well.
