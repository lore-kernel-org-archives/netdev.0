From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Tue, 08 Jan 2008 01:34:41 -0800 (PST)
Message-ID: <20080108.013441.70285847.davem@davemloft.net>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
	<20080107.225417.119463845.davem@davemloft.net>
	<47832BE6.5070906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750715AbYAHJem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 04:34:42 -0500
In-Reply-To: <47832BE6.5070906@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 08 Jan 2008 08:53:10 +0100

> It warns us because rt_cache_get_first() can returns with RCU_BH
> *acquired* or not.

As Herbert mentioned that's a pretty often used paradigm called
conditional locking.  :-)
