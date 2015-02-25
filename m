From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: Add proc entry for next-hop exceptions
Date: Wed, 25 Feb 2015 00:33:05 -0500 (EST)
Message-ID: <20150225.003305.1943185648487924578.davem@davemloft.net>
References: <1424842032-3151-1-git-send-email-chris@rorvick.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chris@rorvick.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424842032-3151-1-git-send-email-chris@rorvick.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Rorvick <chris@rorvick.com>
Date: Tue, 24 Feb 2015 23:27:12 -0600

> Exceptions are added to the FIB in response to ICMP redirects and to
> account for PMTU, but there is little visibility into what the current
> exceptions are.  Add a proc entry for listing the current next-hop
> exceptions
> 
> Signed-off-by: Chris Rorvick <chris@rorvick.com>

Procfs exportation of networking information is deprecated.

New pieces of information should be provided via netlink.
