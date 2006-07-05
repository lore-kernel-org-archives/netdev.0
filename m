From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 2.6.17 0/9] NetXen: ethernet nic driver
Date: Wed, 5 Jul 2006 06:15:16 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0607050602310.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:47975 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S964845AbWGENPc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 09:15:32 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'll be sending a NetXen 1G/10G ethernet driver patch in subsequent 
emails. We have made changes as per the feedback received. We would like 
this driver to be included in mainline kernel.

Kindly review it and feel free to send feedback.

Thanks,
-Amit

Signed-off-by: Amit S. Kale <amitkale@unminc.com>

  Kconfig                      |    5
  Makefile                     |    1
  netxen/Makefile              |   35 +
  netxen/netxen_nic.h          |  998 ++++++++++++++++++++++++++++++++
  netxen/netxen_nic_ethtool.c  |  707 +++++++++++++++++++++++
  netxen/netxen_nic_hdr.h      |  684 ++++++++++++++++++++++
  netxen/netxen_nic_hw.c       | 1308 +++++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_hw.h       |  346 +++++++++++
  netxen/netxen_nic_init.c     | 1263 +++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_ioctl.h    |   75 ++
  netxen/netxen_nic_isr.c      |  430 ++++++++++++++
  netxen/netxen_nic_main.c     | 1228 ++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_niu.c      |  761 +++++++++++++++++++++++++
  netxen/netxen_nic_phan_reg.h |  293 +++++++++
  14 files changed, 8134 insertions(+)
