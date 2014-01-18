From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] bonding: add slave netlink and sysfs
 support
Date: Fri, 17 Jan 2014 18:53:17 -0800 (PST)
Message-ID: <20140117.185317.928852951416595717.davem@davemloft.net>
References: <20140117065316.3194.94624.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, dingtianhong@huawei.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbaARCxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:53:19 -0500
In-Reply-To: <20140117065316.3194.94624.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Thu, 16 Jan 2014 22:57:42 -0800

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

Applied, thanks Scott.
