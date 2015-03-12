From: David Miller <davem@davemloft.net>
Subject: Re: [rhashtable] [ INFO: possible recursive locking detected ]
Date: Wed, 11 Mar 2015 23:41:56 -0400 (EDT)
Message-ID: <20150311.234156.247575265894541661.davem@davemloft.net>
References: <20150312032924.GA12390@wfg-t540p.sh.intel.com>
	<20150312033744.GA13869@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, lkp@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150312033744.GA13869@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 Mar 2015 14:37:45 +1100

> rhashtable: Add annotation to nested lock
>     
> Commit aa34a6cb0478842452bac58edb50d3ef9e178c92 ("rhashtable:
> Add arbitrary rehash function") killed the annotation on the
> nested lock which leads to bitching from lockdep.
>     
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This doesn't apply to net-next, the second hunk gives a reject.
