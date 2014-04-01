From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Apr 1 (netfilter)
Date: Tue, 01 Apr 2014 15:22:03 -0400 (EDT)
Message-ID: <20140401.152203.847120817141929645.davem@davemloft.net>
References: <20140401183907.a5127cadbe7116261096beaa@canb.auug.org.au>
	<533B06A7.5010900@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533B06A7.5010900@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 01 Apr 2014 11:34:15 -0700

> on x86_64:
> 
> net/netfilter/xt_connlimit.c: In function 'connlimit_mt_check':
> net/netfilter/xt_connlimit.c:380:18: warning: division by zero [-Wdiv-by-zero]
> 
> Maybe just use CONNLIMIT_LOCK_SLOTS instead of ARRAY_SIZE(...).

I'd rather see that ARRAY_SIZE() be adjusted to work cleanly for zero
sized array elements.
