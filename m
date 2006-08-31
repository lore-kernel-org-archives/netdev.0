From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Thu, 31 Aug 2006 07:02:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608310543370.23783@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, rob@netxen.com, unmproj@linsyssoft.com,
	shemminger@osdl.org, brazilnut@us.ibm.com, wendyx@us.ibm.com,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:16739 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1751637AbWHaOCc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 10:02:32 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Thank you Stephen, Don and Wendy.
We have incorporated feedbacks which have received since after last post. 
I'll be resending updated patchset in subsequent emails.

We are working on finding out good way of using tables to manage 
compatibility between firmware version number and driver version number.

Kindly review it and feel free to send feedback.

Thanks,
-Amit

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

  MAINTAINERS                              |    7
  drivers/net/Kconfig                      |    5
  drivers/net/Makefile                     |    1
  drivers/net/netxen/Makefile              |   35
  drivers/net/netxen/netxen_nic.h          |  901 +++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ethtool.c  |  696 +++++++++++++++++++
  drivers/net/netxen/netxen_nic_hdr.h      |  611 +++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.c       | 1102 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.h       |  499 +++++++++++++
  drivers/net/netxen/netxen_nic_init.c     | 1089 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
  drivers/net/netxen/netxen_nic_isr.c      |  301 ++++++++
  drivers/net/netxen/netxen_nic_main.c     | 1107 +++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_niu.c      |  779 +++++++++++++++++++++
  drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
  15 files changed, 7403 insertions(+)
