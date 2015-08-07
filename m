From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] RDS-TCP: Network namespace support
Date: Fri, 07 Aug 2015 11:30:11 -0700 (PDT)
Message-ID: <20150807.113011.1424713081901290919.davem@davemloft.net>
References: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com, chien.yen@oracle.com,
	cwang@twopensource.com, dsahern@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1438752224.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed,  5 Aug 2015 01:43:24 -0400

> This patch series contains the set of changes to correctly set up 
> the infra for PF_RDS sockets that use TCP as the transport in multiple
> network namespaces.
> 
> Patch 1 in the series is the minimal set of changes to allow
> a single instance of RDS-TCP to run in any (i.e init_net or other) net
> namespace.  The changes in this patch set ensure that the execution of 
> 'modprobe [-r] rds_tcp' sets up the kernel TCP sockets 
> relative to the current netns, so that RDS applications can send/recv
> packets from that netns, and the netns can later be deleted cleanly.
> 
> Patch 2 of the series further allows multiple RDS-TCP instances,
> one per network namespace. The changes in this patch allows dynamic
> creation/tear-down of RDS-TCP client and server sockets  across all
> current and future namespaces. 
> 
> v2 changes from RFC sent out earlier:
>     David Ahern comments in patch 1, net_device notifier in patch 2, 
>     patch 3 broken off and submitted separately.
> v3: Cong Wang review comments.

Series applied, thanks.
