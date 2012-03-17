From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] eni: fix driver remove function and
 driver probe error path.
Date: Fri, 16 Mar 2012 23:13:45 -0700 (PDT)
Message-ID: <20120316.231345.1740081457384627356.davem@davemloft.net>
References: <20120316115204.GA2028@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030740Ab2CQGOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 02:14:50 -0400
In-Reply-To: <20120316115204.GA2028@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 16 Mar 2012 12:52:04 +0100

> - add eni_do_release() to balance eni_do_init
> - turn the zeroes DMA area into a per device data
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Ouch... applied, thanks a lot!
