From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3.5 00/19] slight optimization of addr compare for
 some modules
Date: Thu, 26 Dec 2013 13:32:00 -0500 (EST)
Message-ID: <20131226.133200.1159110493607479477.davem@davemloft.net>
References: <52BC159C.1000903@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, alexander.h.duyck@intel.com,
	antonio@meshcoding.com, sergei.shtylyov@cogentembedded.com
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BC159C.1000903@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 26 Dec 2013 19:40:12 +0800

> Joe Perches add ether_addr_equal_unaligned to test if
> possibly unaligned to u16 Ethernet addresses are equal.
> 
> If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
> the slightly faster generic routine ether_addr_equal,
> otherwise this uses memcmp.
> 
> So I use the recently added and possibly more efficient
> ether_addr_equal_unaligned to instead of memcmp for slight
> optimization.

Series applied, thanks.
