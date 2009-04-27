From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Sun, 26 Apr 2009 23:11:13 -0700 (PDT)
Message-ID: <20090426.231113.65929407.davem@davemloft.net>
References: <20090427030433.GA17454@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752170AbZD0GLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:11:20 -0400
In-Reply-To: <20090427030433.GA17454@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Mon, 27 Apr 2009 13:04:33 +1000

> Right now we have no upper limit on the size of the route cache hash table.
> On a 128GB POWER6 box it ends up as 32MB:
> 
>     IP route cache hash table entries: 4194304 (order: 9, 33554432 bytes)

Pretty reasonable size for a machine with that much ram.  In fact
perhaps not large enough depending upon your workload. :-)

If it's not suitable for you, as Eric Dumazet explained, pass the
appropriate option on the kernel command line.
