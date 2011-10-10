From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: add missing cast operator in
 drivers/isdn/sc/init.c
Date: Mon, 10 Oct 2011 14:18:49 -0400 (EDT)
Message-ID: <20111010.141849.369289346368485205.davem@davemloft.net>
References: <1318244560-19213-1-git-send-email-corone.il.han@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org
To: corone.il.han@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab1JJSS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:18:58 -0400
In-Reply-To: <1318244560-19213-1-git-send-email-corone.il.han@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Il Han <corone.il.han@gmail.com>
Date: Mon, 10 Oct 2011 20:02:40 +0900

> Add (void __iomem *) to convert the value to the proper type before passing it to readl().
> 
> Signed-off-by: Il Han <corone.il.han@gmail.com>

I've rejected this patch already in the past, and this is because the correct
fix is to change the type of rambase and the variables and datastructures
it is initialized from.
