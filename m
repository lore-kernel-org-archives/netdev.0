From: David Miller <davem@davemloft.net>
Subject: Re: [patch] enic: cleanup vic_provinfo_alloc()
Date: Fri, 11 Jun 2010 18:37:53 -0700 (PDT)
Message-ID: <20100611.183753.13760714.davem@davemloft.net>
References: <20100610075903.GL5483@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, vkolluri@cisco.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745Ab0FLBhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 21:37:42 -0400
In-Reply-To: <20100610075903.GL5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 10 Jun 2010 09:59:03 +0200

> If oui were a null variable then vic_provinfo_alloc() would leak memory.
> But this function is only called from one place and oui is not null so 
> I removed the check.
> 
> I also moved the memory allocation down a line so it was easier to spot.
> (No one ever reads variable declarations).
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied to net-next-2.6, thanks.
