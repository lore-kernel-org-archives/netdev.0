From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25] add bnx2x driver for BCM57710
Date: Thu, 15 Nov 2007 21:19:46 +0200
Message-ID: <1195154386.24548.29.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"masbock" <masbock@us.ibm.com>, "eilong" <eilong@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ram Pai" <linuxram@us.ibm.com>,
	"Philip Oswald" <poswald@novell.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1837 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757732AbXKOTbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 14:31:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the latest version for bnx2x.
Please consider applying to 2.6.25.

This patch also applies cleanly to net-2.6 for anyone that would like to
test it.

Major changes from last post.

* parts of the slowpath have been re-factored.
* slowpath task now runs in work queue context,
  which allowed us to replace the mdelays with msleeps.

ftp link
ftp://Net_sys_anon@ftp1.broadcom.com/0001-add-bnx2x-driver-for-BCM57710.patch

gzipped 
ftp://Net_sys_anon@ftp1.broadcom.com/0001-add-bnx2x-driver-for-BCM57710.patch.gz

I will also post individual files for review as replies to this post.

Thanks,
Eliezer



