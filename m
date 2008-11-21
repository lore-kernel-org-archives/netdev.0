From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert TCP/DCCP ehash rwlocks to spinlocks
Date: Thu, 20 Nov 2008 20:39:46 -0800 (PST)
Message-ID: <20081120.203946.89534386.davem@davemloft.net>
References: <4925B244.3090807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752024AbYKUEjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:39:46 -0500
In-Reply-To: <4925B244.3090807@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 20 Nov 2008 19:53:56 +0100

> Now TCP & DCCP use RCU lookups, we can convert ehash rwlocks to spinlocks.
> 
> /proc/net/tcp and other seq_file 'readers' can safely be converted to 'writers'.
> 
> This should speedup writers, since spin_lock()/spin_unlock()
> only use one atomic operation instead of two for write_lock()/write_unlock()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Nice work, applied, thanks Eric.

Feel free to provide lat_connect and similar before/after numbers for
changes like this in the future :)
