From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8 net-next-2.6] udp: optimisations
Date: Sun, 08 Nov 2009 20:55:22 -0800 (PST)
Message-ID: <20091108.205522.185944441.davem@davemloft.net>
References: <4AF72738.7020606@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lgrijincu@ixiacom.com, opurdila@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752562AbZKIEy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 23:54:57 -0500
In-Reply-To: <4AF72738.7020606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 08 Nov 2009 21:16:56 +0100

> This patch series address UDP scalability problems, we failed to solve in 2007
> (commit 6aaf47fa48d3c44 INET : IPV4 UDP lookups converted to a 2 pass algo)
> we had to revert a bit later.

Looks great, all applied, thanks Eric.

I would even go so far as to say that the cutoff to the second hash
table should be even lower than 10, like maybe 4 or 5.
