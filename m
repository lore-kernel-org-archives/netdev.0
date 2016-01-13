From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: netlink: Fix multicast group storage
 allocation for families with more than one groups
Date: Wed, 13 Jan 2016 10:27:35 -0500 (EST)
Message-ID: <20160113.102735.1851782053420522112.davem@davemloft.net>
References: <20160113075400.GA12580@fi-ourus-dhcp00977.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, jbenc@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexander.sverdlin@nokia.com,
	teppo.o.pennanen@nokia.com
To: matti.vaittinen@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113075400.GA12580@fi-ourus-dhcp00977.emea.nsn-net.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matti Vaittinen <matti.vaittinen@nokia.com>
Date: Wed, 13 Jan 2016 09:54:12 +0200

> Hello again,
> 
>       Second version, Fixed the 'off by one' bug spotted by David.
> 
>       Br.
>         Matti Vaittinen
> 
> Multicast groups are stored in global buffer. Check for needed buffer size
> incorrectly compares buffer size to first id for family. This means that
> for families with more than one mcast id one may allocate too small buffer
> and end up writing rest of the groups to some unallocated memory. Fix the
> buffer size check to compare allocated space to last mcast id for the
> family.
> 
> Tested on ARM using kernel 3.14
> 
> Signed-off-by: Matti Vaittinen <matti.vaittinen@nokia.com>

I inadvertantly applied your original patch, so I'll just fix
the off-by-one error with a seperate commit.

Sorry for the confusion and thanks for fixing this.
