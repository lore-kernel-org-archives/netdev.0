From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: add cpu_relax to busy poll loop
Date: Wed, 28 Aug 2013 17:46:22 -0400 (EDT)
Message-ID: <20130828.174622.268609863849057534.davem@davemloft.net>
References: <20130825072346.31655.84970.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130825072346.31655.84970.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Sun, 25 Aug 2013 10:23:46 +0300

> Add a cpu_relaxt to sk_busy_loop.
> 
> Julie Cummings reported performance issues when hyperthreading is on.
> Arjan van de Ven observed that we should have a cpu_relax() in the
> busy poll loop.
> 
> Reported-by: Julie Cummings <julie.a.cummings@intel.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Applied, thank you.
