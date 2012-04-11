From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] rtnetlink: fix comments
Date: Tue, 10 Apr 2012 21:32:59 -0700
Message-ID: <20120410213259.10009908@nehalam.linuxnetplumber.net>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
	<1334009344.7150.268.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42214 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab2DKEdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 00:33:07 -0400
In-Reply-To: <1334009344.7150.268.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix spelling and references in rtnetlink.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
v2 - fix bogus comment on get_link_af_size and add get_tx_queues

--- a/include/net/rtnetlink.h	2012-02-27 08:43:02.400935781 -0800
+++ b/include/net/rtnetlink.h	2012-04-10 21:19:01.369508395 -0700
@@ -41,9 +41,11 @@ static inline int rtnl_msg_family(const
  *	@get_size: Function to calculate required room for dumping device
  *		   specific netlink attributes
  *	@fill_info: Function to dump device specific netlink attributes
- *	@get_xstats_size: Function to calculate required room for dumping devic
+ *	@get_xstats_size: Function to calculate required room for dumping device
  *			  specific statistics
  *	@fill_xstats: Function to dump device specific statistics
+ *	@get_tx_queues: Function to determine number of transmit queues to create when
+ *		        creating a new device.
  */
 struct rtnl_link_ops {
 	struct list_head	list;
@@ -94,7 +96,7 @@ extern void	rtnl_link_unregister(struct
  * 	@fill_link_af: Function to fill IFLA_AF_SPEC with address family
  * 		       specific netlink attributes.
  * 	@get_link_af_size: Function to calculate size of address family specific
- * 			   netlink attributes exlusive the container attribute.
+ * 			   netlink attributes.
  *	@validate_link_af: Validate a IFLA_AF_SPEC attribute, must check attr
  *			   for invalid configuration settings.
  * 	@set_link_af: Function to parse a IFLA_AF_SPEC attribute and modify
