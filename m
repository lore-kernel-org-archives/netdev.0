From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2.6.18-rc7 0/9] NetXen: 1G/10G Ethernet Driver
Date: Fri, 15 Sep 2006 11:33:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609151124560.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jeff@garzik.org, Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:1594 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S932163AbWIOSdu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 14:33:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Thank you Jeff.
We have incorporated feedbacks which received. I'll be sending updated 
patchset in subsequent emails.

-Amit

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

  MAINTAINERS                              |    7
  drivers/net/Kconfig                      |    5
  drivers/net/Makefile                     |    1
  drivers/net/netxen/Makefile              |   35
  drivers/net/netxen/netxen_nic.h          |  913 ++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ethtool.c  |  715 +++++++++++++++++++
  drivers/net/netxen/netxen_nic_hdr.h      |  618 ++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.c       |  947 +++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.h       |  467 ++++++++++++
  drivers/net/netxen/netxen_nic_init.c     | 1143 +++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
  drivers/net/netxen/netxen_nic_isr.c      |  221 +++++
  drivers/net/netxen/netxen_nic_main.c     | 1116 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_niu.c      |  800 +++++++++++++++++++++
  drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
  15 files changed, 7258 insertions(+)
