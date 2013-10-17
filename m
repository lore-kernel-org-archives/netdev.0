From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] netdev: inet_timewait_sock.h missing semi-colon
 when KMEMCHECK is enabled
Date: Thu, 17 Oct 2013 15:57:24 -0400 (EDT)
Message-ID: <20131017.155724.740238353182278175.davem@davemloft.net>
References: <1381762088-18880-1-git-send-email-treding@nvidia.com>
	<525C47C0.2000907@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thierry.reding@gmail.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, broonie@kernel.org,
	netdev@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525C47C0.2000907@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 14 Oct 2013 12:36:32 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix (a few hundred) build errors due to missing semi-colon when
> KMEMCHECK is enabled:
> 
>   include/net/inet_timewait_sock.h:139:2: error: expected ',', ';' or '}' before 'int'
>   include/net/inet_timewait_sock.h:148:28: error: 'const struct inet_timewait_sock' has no member named 'tw_death_node'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
