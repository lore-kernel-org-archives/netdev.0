From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 0/4] ss: Get netlink sockets info via sock-diag (v2)
Date: Wed,  5 Jun 2013 12:41:57 +0400
Message-ID: <1370421721-30814-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34530 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414Ab3FEIoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 04:44:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:00:25AM -0700, Stephen Hemminger wrote:
> Since this depends on functionality not in the upstream kernel.
> Resubmit this during the 3.10 merge window. At the start of the merge
> window, headers are synchronized with the kernel headers.

Netlink socket diag is in the upstream kernel since 3.10-rc1.

v2: Update kernel headers

Andrey Vagin (4):
  ss: handle socket diag request in a separate function
  ss: create a function to print info about netlink sockets
  ss: show destination address for netlink sockets
  ss: Get netlink sockets info via sock-diag (v2)

 include/linux/netlink_diag.h |  52 ++++++++++
 misc/ss.c                    | 242 +++++++++++++++++++++++++++++--------------
 2 files changed, 216 insertions(+), 78 deletions(-)
 create mode 100644 include/linux/netlink_diag.h

-- 
1.8.2
