From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Sat, 17 Nov 2007 22:46:40 +0100
Message-ID: <20071117214640.GA16314@one.firstfloor.org>
References: <473B69D5.2050805@cosmosbay.com> <p73r6isc6ev.fsf@bingen.suse.de> <473C0297.5090004@cosmosbay.com> <p73fxz5auk5.fsf@bingen.suse.de> <473F1589.9080101@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:45476 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbXKQVqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 16:46:43 -0500
Content-Disposition: inline
In-Reply-To: <473F1589.9080101@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The 25.000.000 ns and 88.000.000 ns numbers where on an empty table, but 
> large (16 MB of memory)

This would mean that cond_resched() needs ~4x as much time as checking
an empty bucket. I find that somewhat hard to believe.

-Andi
