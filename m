From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Thu, 08 Oct 2009 14:31:07 -0700 (PDT)
Message-ID: <20091008.143107.119291995.davem@davemloft.net>
References: <4ACE023D.9030208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vegard.nossum@gmail.com, mingo@elte.hu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756386AbZJHVbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 17:31:12 -0400
In-Reply-To: <4ACE023D.9030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Oct 2009 17:16:13 +0200

> Since commit a98b65a3 (net: annotate struct sock bitfield), we lost 8 bytes
> in struct sock on 64bits arches because of kmemcheck_bitfield_end(flags) misplacement.
 ...
> sizeof(struct good) = 16, sizeof(struct bad) = 24
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Good catch, thanks Eric.

Applied to net-2.6
