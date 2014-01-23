From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 net-next-for-3.13 0/2] iplink: add support for bonding slave
Date: Thu, 23 Jan 2014 17:52:52 +0100
Message-ID: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:48230 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbaAWQw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 11:52:58 -0500
Received: by mail-wg0-f47.google.com with SMTP id m15so1822428wgh.14
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 08:52:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  introduce support for slave info data
  iplink: add support for bonding slave

 include/linux/if_link.h | 19 ++++++-----
 ip/Makefile             |  2 +-
 ip/ip_common.h          |  4 +++
 ip/ipaddress.c          | 54 +++++++++++++++++++----------
 ip/iplink.c             | 21 ++++++++++--
 ip/iplink_bond_slave.c  | 90 +++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 160 insertions(+), 30 deletions(-)
 create mode 100644 ip/iplink_bond_slave.c

-- 
1.8.3.1
