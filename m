From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Fri, 18 Aug 2006 07:38:39 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608180713480.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:35879 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1030425AbWHROij
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:38:39 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'll be sending a NetXen Multi port 1G/10G ethernet driver patch in 
subsequent emails. This set of patches have changes as per the 
suggestions, which we received since last post.

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
  drivers/net/netxen/netxen_nic_hw.c       | 1097 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_hw.h       |  500 ++++++++++++++
  drivers/net/netxen/netxen_nic_init.c     | 1090 ++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_ioctl.h    |   75 ++
  drivers/net/netxen/netxen_nic_isr.c      |  300 ++++++++
  drivers/net/netxen/netxen_nic_main.c     | 1107 +++++++++++++++++++++++++++++++
  drivers/net/netxen/netxen_nic_niu.c      |  778 +++++++++++++++++++++
  drivers/net/netxen/netxen_nic_phan_reg.h |  195 +++++
  15 files changed, 7398 insertions(+)
