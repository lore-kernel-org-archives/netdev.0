From: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
Subject: [PATCH 0/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 03:45:23 -0700 (PDT)
Message-ID: <Pine.LNX.4.33.0605250339490.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sanjeev@unminc.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:63853 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S965116AbWEYKpZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 06:45:25 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'll be sending a NetXen (formerly Universal Network Machines) 1G/10G in
subsequent emails. This is a revised version of the UNM driver posted
earlier. We have tried to make changes as per the feedback received. 
We would like this driver to be inluded in mainline kernel.
Kindly review it and feel free to get back to me for any further
feedback/queries/comments.

Thanks.
-Amit

Signed-off-by: Amit S. Kale <amitkale@unminc.com>

 Kconfig                      |    5 
 Makefile                     |    1 
 netxen/Makefile              |   35 +
 netxen/netxen_nic.h          |  950 +++++++++++++++++++++++++++++++
 netxen/netxen_nic_ethtool.c  |  802 ++++++++++++++++++++++++++
 netxen/netxen_nic_hdr.h      |  682 ++++++++++++++++++++++
 netxen/netxen_nic_hw.c       | 1289 +++++++++++++++++++++++++++++++++++++++++++
 netxen/netxen_nic_hw.h       |  339 +++++++++++
 netxen/netxen_nic_init.c     | 1219 ++++++++++++++++++++++++++++++++++++++++
 netxen/netxen_nic_ioctl.h    |   75 ++
 netxen/netxen_nic_isr.c      |  428 ++++++++++++++
 netxen/netxen_nic_main.c     | 1209 ++++++++++++++++++++++++++++++++++++++++
 netxen/netxen_nic_niu.c      |  770 +++++++++++++++++++++++++
 netxen/netxen_nic_phan_reg.h |  195 ++++++
 14 files changed, 7999 insertions(+)

