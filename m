From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Lower/upper bucket may map to
 same lock while shrinking
Date: Tue, 13 Jan 2015 00:25:39 -0500 (EST)
Message-ID: <20150113.002539.865888654705925013.davem@davemloft.net>
References: <20150112232217.GA5277@wfg-t540p.sh.intel.com>
	<20150112235821.GB16617@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, lkp@01.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150112235821.GB16617@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 12 Jan 2015 23:58:21 +0000

> Each per bucket lock covers a configurable number of buckets. While
> shrinking, two buckets in the old table contain entries for a single
> bucket in the new table. We need to lock down both while linking.
> Check if they are protected by different locks to avoid a recursive
> lock.
> 
> Fixes: 97defe1e ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
