From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/24] net, diet: Make LPF filter optional
Date: Mon, 05 May 2014 23:10:15 -0400 (EDT)
Message-ID: <20140505.231015.1267261274092331777.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-11-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731AbaEFDKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:10:16 -0400
In-Reply-To: <1399328773-6531-11-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:59 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Small systems don't need the LPF filter, so make it all
> optional
> 
> Saves about 4K text
> 
>    text	   data	    bss	    dec	    hex	filename
>  483545	  19371	  13480	 516396	  7e12c	net/built-in.o-wo-filter
>  487675	  19275	  13480	 520430	  7f0ee	net/built-in.o-with-filter
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

I think you highly underestimate how much "small systems" use
packet capturing and thus BPF.
