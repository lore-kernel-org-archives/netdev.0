From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/14] mm: memcontrol: switch to the updated jump-label
 API
Date: Tue, 08 Dec 2015 11:28:20 -0500 (EST)
Message-ID: <20151208.112820.1456343214602612286.davem@davemloft.net>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
	<1449588624-9220-15-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449588624-9220-15-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue,  8 Dec 2015 10:30:24 -0500

> According to <linux/jump_label.h> the direct use of struct static_key
> is deprecated. Update the socket and slab accounting code accordingly.
> 
> Reported-by: Jason Baron <jbaron@akamai.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>
