From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/8] dcbnl: Major simplifications
Date: Wed, 13 Jun 2012 14:54:53 +0200
Message-ID: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753096Ab2FMMzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dcbnl code is overly complicated when constructing the reply
message. This series of patches simplifies the process and
introduces consistent error codes allowing user space to figure
out what went wrong.

Patches have been tested with ixgbe in a FCoE setup.

Thomas Graf (8):
  dcbnl: Prepare framework to shorten handling functions
  dcbnl: Shorten all command handling functions
  dcbnl: Remove now unused dcbnl_reply()
  dcbnl: Use dcbnl_newmsg() where possible
  dcbnl: Return consistent error codes
  dcbnl: Move dcb app lookup code into dcb_app_lookup()
  dcbnl: Move dcb app allocation into dcb_app_add()
  dcbnl: Use type safe nlmsg_data()

 net/dcb/dcbnl.c | 1169 +++++++++++++++++++------------------------------------
 1 files changed, 401 insertions(+), 768 deletions(-)

-- 
1.7.7.6
