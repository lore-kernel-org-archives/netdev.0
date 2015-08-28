From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] rhashtable-test: calculate max_entries value by
 default
Date: Fri, 28 Aug 2015 13:11:53 +0200
Message-ID: <20150828111153.GJ32206@pox.localdomain>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
 <1440757685-14241-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440757685-14241-3-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/28/15 at 12:28pm, Phil Sutter wrote:
> A maximum table size of 64k entries is insufficient for the multiple
> threads test even in default configuration (10 threads * 50000 objects =
> 500000 objects in total). Since we know how many objects will be
> inserted, calculate the max size unless overridden by parameter.
> 
> Note that specifying the exact number of objects upon table init won't
> suffice as that value is being rounded down to the next power of two -
> anticipate this by rounding up to the next power of two in beforehand.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Thomas Graf <tgraf@suug.ch>

Thanks for doing this work.
