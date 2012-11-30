From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: improve bitops usage
Date: Fri, 30 Nov 2012 12:11:22 -0500 (EST)
Message-ID: <20121130.121122.1152311583758662933.davem@davemloft.net>
References: <1354188465-29012-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031268Ab2K3RLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:11:24 -0500
In-Reply-To: <1354188465-29012-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Thu, 29 Nov 2012 20:27:45 +0900

> This improves bitops usages in several points:
> 
> - Convert u64 to a proper bitmap declaration.  This enables to remove
>   superfluous typecasting from 'u64' to 'unsigned long *'.
> 
> - Convert superfluous atomic bitops to non atomic bitops.  The bitmap
>   is allocated on the stack and it is not accessed by any other threads,
>   so using atomic bitops is not necessary.
> 
> - Use find_next_zero_bit and find_next_zero_bit instead of calling
>   test_bit() for each bit.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Applied, thanks.
