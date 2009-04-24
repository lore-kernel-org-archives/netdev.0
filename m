From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/4] Add bnx2 iSCSI support.
Date: Thu, 23 Apr 2009 17:22:39 -0700
Message-ID: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: anilgv@broadcom.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
To: davem@davemloft.net, michaelc@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4450 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755320AbZDXBOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 21:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New Broadcom iSCSI driver for review.  Compared to the last 
version we posted in 2008, we've changed it to use a separate
and private MAC address/IP address for iSCSI.  We are creating
a UIO interface to handle the non-offloaded packets such as
ARP, etc. in user space.  Thanks.



