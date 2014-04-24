From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 23 Apr 2014 22:45:20 -0400 (EDT)
Message-ID: <20140423.224520.1593121538943289001.davem@davemloft.net>
References: <20140424114726.07876050b5b805463a085191@canb.auug.org.au>
	<1398306278.29638.42.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	kubakici@wp.pl, carolyn.wyborny@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398306278.29638.42.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Apr 2014 19:24:38 -0700

> On Thu, 2014-04-24 at 11:47 +1000, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Today's linux-next merge of the net-next tree got a conflict in
>> drivers/net/ethernet/intel/igb/e1000_mac.c between commit c5ffe7e1f745
>> ("e1000e/igb/ixgbe/i40e: fix message terminations") from the net tree
>> and
>> commit c75c4edfc38d ("igb: Cleanups for messaging") from the net-next
>> tree.
>> 
>> I fixed it up (the former was a superset of the latter) and can carry
>> the
>> fix as necessary (no action is required).
> 
> Huh, I thought the commit c75c4edfc38d ("igb: Cleanups for messaging")
> in Dave's net-next already took into account the changes in net.  I will
> take a look at your fix Stephen, thanks for letting us know.

Stephen may have pulled net-next before that went in.
