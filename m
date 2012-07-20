From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: further seperate dst_entry.__refcnt from cache
 contention
Date: Fri, 20 Jul 2012 13:29:34 -0700 (PDT)
Message-ID: <20120720.132934.854459589738348753.davem@davemloft.net>
References: <1342813587-31601-1-git-send-email-nzimmer@sgi.com>
	<1342815411.2626.7936.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nzimmer@sgi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Robin.Holt@sgi.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab2GTU3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 16:29:37 -0400
In-Reply-To: <1342815411.2626.7936.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jul 2012 22:16:51 +0200

> Another idea concerning very hot dst would be to clone them on demand.

The FIB info cached dsts could also be made per-cpu.

And yes, the only reason I'm entertaining that idea now is the fact
that we'll have the number of dsts in the system under control.
