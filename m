From: Stephen Hemminger <shemminger@vyatta.com>
Subject: iproute2: l2tp support
Date: Thu, 29 Dec 2011 09:42:14 -0800
Message-ID: <20111229094214.238a1b8f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54193 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753420Ab1L2RmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 12:42:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I updated the latest iproute2 in git to include support for L2TP.
It is based on James's code but instead of using libnl, it uses netlink
directly (like I asked when rejecting the original patch).

In order to make netlink code in iproute2 cleaner, several libnetlink
have been updated.
  * unused junk argument to rtnl_dump_filter and rtnl_talk have
    been removed.
  * addattr_xx functions for building attributes added.
  * rta_getattr_XXX inline functions for the common case of
    looking at basic type attributes

This will show up in 3.2 version of iproute2 which is ready and
waiting for kernel release.
