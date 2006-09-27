From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2.6.18 0/9] NetXen: 1G/10G Ethernet Driver
Date: Wed, 27 Sep 2006 08:27:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609270821160.18527@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Sanjeev Jorapur <sanjeev@netxen.com>, Rob Mapes <rob@netxen.com>,
	unmproj@linsyssoft.com, brazilnut@us.ibm.com, wendyx@us.ibm.com,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:47703 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S964930AbWI0P1r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 11:27:47 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

We have incorporated feedbacks which we received since last post. I'll be 
sending updated patchset wrt 2.6.18 in subsequent emails.

Thanks,
-Amit

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

  MAINTAINERS                              |    7
  drivers/net/Kconfig                      |    5
  drivers/net/Makefile                     |    1
  drivers/net/netxen/Makefile              |   35
  drivers/net/netxen/netxen_nic.h          |  910 ++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ethtool.c  |  715 +++++++++++++++++++
  drivers/net/netxen/netxen_nic_hdr.h      |  618 ++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.c       |  936 +++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.h       |  480 +++++++++++++
  drivers/net/netxen/netxen_nic_init.c     | 1143 +++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
  drivers/net/netxen/netxen_nic_isr.c      |  221 +++++
  drivers/net/netxen/netxen_nic_main.c     | 1116 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_niu.c      |  800 +++++++++++++++++++++
  drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
  15 files changed, 7257 insertions(+)
