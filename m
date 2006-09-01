From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Fri, 1 Sep 2006 11:44:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609011140050.13052@dut39>
References: <Pine.LNX.4.64.0608310543370.23783@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sanjeev Jorapur <sanjeev@netxen.com>,
	Wen Xiong <wendyx@us.ibm.com>, Jeff Garzik <jeff@garzik.org>,
	Don Fry <brazilnut@us.ibm.com>, Rob Mapes <rob@netxen.com>,
	Amit Kale <amitkale@netxen.com>,
	Stephen Hemminger <shemminger@osdl.org>, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:53612 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1750755AbWIASoV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 14:44:21 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0608310543370.23783@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This entire patch is available at,
http://www.netxen.com/products/downloads/netxen-2.6.17.patch.zip

Thanks,
pradeep

On Thu, 31 Aug 2006, Amit S. Kale wrote:

> Hi All,
>
> Thank you Stephen, Don and Wendy.
> We have incorporated feedbacks which have received since after last post. 
> I'll be resending updated patchset in subsequent emails.
>
> We are working on finding out good way of using tables to manage 
> compatibility between firmware version number and driver version number.
>
> Kindly review it and feel free to send feedback.
>
> Thanks,
> -Amit
>
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
>
> MAINTAINERS                              |    7
> drivers/net/Kconfig                      |    5
> drivers/net/Makefile                     |    1
> drivers/net/netxen/Makefile              |   35
> drivers/net/netxen/netxen_nic.h          |  901 +++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_ethtool.c  |  696 +++++++++++++++++++
> drivers/net/netxen/netxen_nic_hdr.h      |  611 +++++++++++++++++
> drivers/net/netxen/netxen_nic_hw.c       | 1102 
> ++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_hw.h       |  499 +++++++++++++
> drivers/net/netxen/netxen_nic_init.c     | 1089 
> ++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
> drivers/net/netxen/netxen_nic_isr.c      |  301 ++++++++
> drivers/net/netxen/netxen_nic_main.c     | 1107 
> +++++++++++++++++++++++++++++++
> drivers/net/netxen/netxen_nic_niu.c      |  779 +++++++++++++++++++++
> drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
> 15 files changed, 7403 insertions(+)
>
>
>
