From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds_rdma: don't assume infiniband device is PCI
Date: Thu, 05 Jan 2012 13:57:51 -0500 (EST)
Message-ID: <20120105.135751.2230446777137893740.davem@davemloft.net>
References: <ed54708d-990e-4c8f-8057-50a70f93d3d8@default>
	<20120105170523.GA19022@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dledford@redhat.com,
	Jes.Sorensen@redhat.com, rds-devel@oss.oracle.com
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105170523.GA19022@oc1711230544.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Thu, 5 Jan 2012 15:05:24 -0200

> On Thu, Jan 05, 2012 at 08:56:34AM -0800, Venkat Venkatsubra wrote:
>> Hi Cascardo,
>> 
>> Your changes look good to me.
>> But our latest code doesn't use this rdsibdev_to_node macro anywhere.
>> Checking with the people in my group who know the history of the NUMA feature.
>> Trying to find out if the call to kzalloc_node() can be replaced by kzalloc().
>> In which case this macro can be removed.
>> 
>> I will keep you posted.
>> 
>> Venkat
>> 
> 
> Hi, Venkat.
> 
> Do you have any public tree where we can track the last changes in RDS?
> Note that I have changed ibsdev_to_node, which rdsibdev_to_node makes
> use of. Anyway, replacing kzalloc_node with kzalloc has crossed my mind,
> but since I was not sure if this would affect latency of RDS in any use
> cases, I kept that and used a better function to get the node from the
> device. And we have dev_to_node since 2.6.20, so it should not be a
> problem to use it.
> 
> If possible, keep everyone copied and avoid top posting.

Indeed, otherwise it's impossible for anyone to follow the progress on
this patch.  If anything, you should never remove netdev from the CC:
list when discussing a patch.  Otherwise the followups don't make into
our patch tracking system at:

http://patchwork.ozlabs.org/project/netdev/list/
