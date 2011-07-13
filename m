From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] slip: fix MTU comparation operation when
 reallocating buffers
Date: Wed, 13 Jul 2011 02:32:26 -0700 (PDT)
Message-ID: <20110713.023226.1551271437773589147.davem@davemloft.net>
References: <CAKh5nabAU=nYJdcbM55J=FDhcrZgW4G+vOBuOjT8TwniT457Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965188Ab1GMJc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 05:32:28 -0400
In-Reply-To: <CAKh5nabAU=nYJdcbM55J=FDhcrZgW4G+vOBuOjT8TwniT457Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Wed, 13 Jul 2011 11:46:17 +0400

> In sl_realloc_bufs() there is no reason to check if the requested MTU greater
> than or equal to the current MTU value as this function called only
> when requested
> MTU not equals to the current value. So, the ">=" operation can be
> safely replaced
> with the ">".
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>

Patch corrupted by email client:

>  			printk(KERN_WARNING "%s: unable to grow slip buffers, MTU change
> cancelled.\n",

That should be one line.

I applied this by hand.
