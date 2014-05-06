From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/24] net, diet: Make MIB statistics collections
 depend on PROC_FS
Date: Mon, 05 May 2014 23:05:58 -0400 (EDT)
Message-ID: <20140505.230558.1799358791667540111.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-15-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731AbaEFDF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:05:59 -0400
In-Reply-To: <1399328773-6531-15-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:03 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> When PROC_FS is not compiled in we don't need the statistics
> gathering code, as the only way to see the output is through
> /proc. Saves about 5k text, likely more in dynamic memory.
> 
>    text    data     bss     dec     hex filename
>  386302    8993   12564  407859   63933 net/built-in.o-with-mib
>  381542    8933   12564  403039   6265f net/built-in.o-wo-mib
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Congratulations, you just broke ipv6 device address netlink
dumps amongst other things.
