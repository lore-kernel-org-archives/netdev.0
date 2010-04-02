From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: keep the old behavior on SMP without rps
Date: Thu, 01 Apr 2010 18:44:57 -0700 (PDT)
Message-ID: <20100401.184457.00383135.davem@davemloft.net>
References: <4BB2E8B6.8010201@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42606
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759134Ab0DBBo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:44:56 -0400
In-Reply-To: <4BB2E8B6.8010201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 31 Mar 2010 14:16:22 +0800

> keep the old behavior on SMP without rps
> 
> RPS introduces a lock operation to per cpu variable input_pkt_queue on
> SMP whenever rps is enabled or not. On SMP without RPS, this lock isn't
> needed at all.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
