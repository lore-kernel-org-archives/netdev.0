From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/4] atl1: Revised Attansic L1 ethernet driver
Date: Sun, 19 Nov 2006 14:28:17 -0600
Message-ID: <20061119202817.GA29736@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, romieu@fr.zoreil.com, csnook@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:17132 "EHLO
	imf21aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S933164AbWKSU2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 15:28:19 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based upon feedback from Stephen Hemminger and Francois Romieu, please
consider this resubmitted patchset that provides support for the Attansic 
L1 gigabit ethernet adapter.  This patchset is built against 2.6.19-rc6.  
The original patchset was submitted 20060927.

The monolithic version of this patchset may be found at:
ftp://hogchain.net/pub/linux/m2v/attansic/kernel_driver/atl1-2.0.2/atl1-2.0.2-kernel2.6.19.rc6.patch.bz2

As a reminder, this driver a modified version of the Attansic reference 
driver for the L1 ethernet adapter.  Attansic has granted permission for 
its inclusion in the mainline kernel.

The patch contains:

 Kconfig             |   12 
 Makefile            |    1 
 atl1/Makefile       |   30 
 atl1/atl1.h         |  251 +++++
 atl1/atl1_ethtool.c |  530 ++++++++++
 atl1/atl1_hw.c      |  840 +++++++++++++++++
 atl1/atl1_hw.h      |  991 ++++++++++++++++++++
 atl1/atl1_main.c    | 2551 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 atl1/atl1_osdep.h   |   78 +
 atl1/atl1_param.c   |  203 ++++
 10 files changed, 5487 insertions(+)
