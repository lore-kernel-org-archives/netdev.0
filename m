From: David Miller <davem@davemloft.net>
Subject: Re: rps: keep the old behavior on SMP without rps
Date: Tue, 30 Mar 2010 22:40:04 -0700 (PDT)
Message-ID: <20100330.224004.258514158.davem@davemloft.net>
References: <4BB2DD95.90402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757065Ab0CaFkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:40:04 -0400
In-Reply-To: <4BB2DD95.90402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 31 Mar 2010 13:28:53 +0800

> keep the old behavior on SMP without rps
> 
> RPS introduces a lock operation to per cpu variable input_pkt_queue on
> SMP whenever rps is enabled or not. On SMP without RPS, this lock isn't
> needed at all.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Instead of peppering the file with lots of ifdefs, encapsulate
the thing thats changing into a set of inline functions.
