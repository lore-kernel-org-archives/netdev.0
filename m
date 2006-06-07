From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 0/9] NetXen 1G/10G ethernet driver patch with corrections
Date: Wed, 7 Jun 2006 02:30:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0606070221280.10031@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:13438 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S932083AbWFGJam
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 05:30:42 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'll be sending a NetXen 1G/10G ethernet driver patch in
subsequent emails. We have made changes as per the feedback received.
We would like this driver to be inluded in mainline kernel.

Kindly review it and feel free to send feedback.

Thanks.
-Amit


Signed-off-by: Amit S. Kale <amitkale@unminc.com>

  Kconfig                      |    5
  Makefile                     |    1
  netxen/Makefile              |   35 +
  netxen/netxen_nic.h          |  998 ++++++++++++++++++++++++++++++++
  netxen/netxen_nic_ethtool.c  |  775 +++++++++++++++++++++++++
  netxen/netxen_nic_hdr.h      |  684 ++++++++++++++++++++++
  netxen/netxen_nic_hw.c       | 1308 
+++++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_hw.h       |  346 +++++++++++
  netxen/netxen_nic_init.c     | 1263 
+++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_ioctl.h    |   75 ++
  netxen/netxen_nic_isr.c      |  430 ++++++++++++++
  netxen/netxen_nic_main.c     | 1228 
++++++++++++++++++++++++++++++++++++++++
  netxen/netxen_nic_niu.c      |  761 +++++++++++++++++++++++++
  netxen/netxen_nic_phan_reg.h |  293 +++++++++
  14 files changed, 8202 insertions(+)
~

