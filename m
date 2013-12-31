From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: allow large buffer size to have page size
Date: Tue, 31 Dec 2013 16:54:29 -0500 (EST)
Message-ID: <20131231.165429.1269765488967765151.davem@davemloft.net>
References: <1387820069-13623-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com,
	linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387820069-13623-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 23 Dec 2013 15:34:29 -0200

> Since commit 52367a763d8046190754ab43743e42638564a2d1
> ("cxgb4/cxgb4vf: Code cleanup to enable T4 Configuration File support"),
> we have failures like this during cxgb4 probe:
> 
> cxgb4 0000:01:00.4: bad SGE FL page buffer sizes [65536, 65536]
> cxgb4: probe of 0000:01:00.4 failed with error -22
> 
> This happens whenever software parameters are used, without a
> configuration file. That happens when the hardware was already
> initialized (after kexec, or after csiostor is loaded).
> 
> It happens that these values are acceptable, rendering fl_pg_order equal
> to 0, which is the case of a hard init when the page size is equal or
> larger than 65536.
> 
> Accepting fl_large_pg equal to fl_small_pg solves the issue, and
> shouldn't cause any trouble besides a possible performance reduction
> when smaller pages are used. And that can be fixed by a configuration
> file.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Can I get a review from one of the cxgb4 driver maintainers?

Thanks.
