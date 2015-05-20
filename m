From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] IPv6 ECMP route add/replace fixes
Date: Wed, 20 May 2015 12:03:40 -0400 (EDT)
Message-ID: <20150520.120340.894954416645925582.davem@davemloft.net>
References: <20150516.171823.1391641644498357985.davem@davemloft.net>
	<cover.1431974706.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	roopa@cumulusnetworks.com
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1431974706.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 18 May 2015 20:53:50 +0200 (CEST)

> (1) When adding a nexthop of a multipath route fails (e.g. because of a
> conflict with an existing route), we are supposed to delete nexthops
> already added. However, currently we try to also delete all nexthops we
> haven't even tried to add yet so that a "ip route add" command can
> actually remove pre-existing routes if it fails.
> 
> (2) Attempt to replace a multipath route results in a broken siblings
> linked list. Following commands (like "ip route del") can then either
> follow a link into freed memory or end in an infinite loop (if the slab
> object has been reused).
> 
> v2: fix an omission in first patch
> 
> v3: change the semantics of replace operation to better match IPv4

Series applied, thanks.
