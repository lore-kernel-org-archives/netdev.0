From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net dst: use a percpu_counter to track entries
Date: Mon, 11 Oct 2010 13:07:58 -0700 (PDT)
Message-ID: <20101011.130758.70192030.davem@davemloft.net>
References: <1286555854.2959.605.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755105Ab0JKUHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 16:07:36 -0400
In-Reply-To: <1286555854.2959.605.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Oct 2010 18:37:34 +0200

> struct dst_ops tracks number of allocated dst in an atomic_t field,
> subject to high cache line contention in stress workload.
> 
> Switch to a percpu_counter, to reduce number of time we need to dirty a
> central location. Place it on a separate cache line to avoid dirtying
> read only fields.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

When I first read the subject line for this patch, I was
scared, because I thought you were using a percpu counter
for dst entry refcounts :-)

Anyways this is fine, applied, thanks!
