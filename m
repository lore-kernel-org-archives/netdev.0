From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 0/2] bonding: add slave netlink and sysfs
 support
Date: Fri, 17 Jan 2014 15:47:10 +0800
Message-ID: <52D8DFFE.20603@huawei.com>
References: <20140117065316.3194.94624.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <roopa@cumulusnetworks.com>,
	<shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>, <vfalico@redhat.com>,
	<fubar@us.ibm.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40533 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaAQHsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 02:48:01 -0500
In-Reply-To: <20140117065316.3194.94624.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/17 14:57, Scott Feldman wrote:
> v2:
> 
>   - Address review comment from Ding (and Veacesiav): handle kobj cleanup
>     if sysfs_create_file() fails when adding slave attribute nodes.
> 
> v1:
> 
>   The following series adds bonding slave netlink and sysfs interfaces.
>   Slave interfaces get a new IFLA_SLAVE set of netlink attributes, along
>   with RTM_NEWLINK notification when slave's active status changes.  The
>   sysfs interface adds read-only nodes for slave attributes under a /slave
>   dir, simliar to how bond interfaces get a /bonding dir for bonding
>   attributes.
> 
> ---
> 
> Scott Feldman (2):
>       bonding: add sysfs /slave dir for bond slave devices.
>       bonding: add netlink attributes to slave link dev
> 
> 
>  drivers/net/bonding/Makefile           |    2 
>  drivers/net/bonding/bond_main.c        |   28 ++++++
>  drivers/net/bonding/bond_netlink.c     |   36 ++++++++
>  drivers/net/bonding/bond_procfs.c      |   12 ---
>  drivers/net/bonding/bond_sysfs_slave.c |  144 ++++++++++++++++++++++++++++++++
>  drivers/net/bonding/bonding.h          |   15 +++
>  include/linux/netdevice.h              |    5 +
>  include/uapi/linux/if_link.h           |   13 +++
>  net/core/rtnetlink.c                   |   54 ++++++++++++
>  9 files changed, 294 insertions(+), 15 deletions(-)
>  create mode 100644 drivers/net/bonding/bond_sysfs_slave.c
> 
Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>
