From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] dev_alloc_name: fix kernel-doc formatting, typos, etc.
Date: Fri, 17 Dec 2010 13:40:46 -0800
Message-ID: <20101217134046.61eb94dd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:26536 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0LQVlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 16:41:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

The '%' sign needs to be duplicated so that the kernel-doc tools
will print a '%' sign instead of just printed "ltd".

Also fixes some punctuation/grammar and formatting.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/dev.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- lnx-2637-rc6.orig/net/core/dev.c
+++ lnx-2637-rc6/net/core/dev.c
@@ -925,13 +925,14 @@ static int __dev_alloc_name(struct net *
  *	@dev: device
  *	@name: name format string
  *
- *	Passed a format string - eg "lt%d" it will try and find a suitable
+ *	Passed a format string - e.g. "lt%%d", it will try to find a suitable
  *	id. It scans list of devices to build up a free map, then chooses
  *	the first empty slot. The caller must hold the dev_base or rtnl lock
  *	while allocating the name and adding the device in order to avoid
  *	duplicates.
- *	Limited to bits_per_byte * page size devices (ie 32K on most platforms).
- *	Returns the number of the unit assigned or a negative errno code.
+ *	Limited to bits_per_byte * page size devices
+ *	(i.e. 32K on most platforms).
+ *	Returns: the number of the unit assigned or a negative errno code.
  */
 
 int dev_alloc_name(struct net_device *dev, const char *name)
