From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 9p: fix off by one causing access violations and
 memory corruption
Date: Thu, 11 Jul 2013 11:36:30 -0700 (PDT)
Message-ID: <20130711.113630.663397013864889538.davem@davemloft.net>
References: <1373563014-4645-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373563014-4645-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu, 11 Jul 2013 13:16:54 -0400

> p9_release_pages() would attempt to dereference one value past the end of
> pages[]. This would cause the following crashes:
 ...
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied and queued up for -stable.
