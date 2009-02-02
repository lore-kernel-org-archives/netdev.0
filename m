From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Is 64k bind patch making bad assumption?
Date: Mon, 2 Feb 2009 10:35:15 -0800
Message-ID: <20090202103515.60788d0f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59832 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775AbZBBSfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 13:35:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch to allow more that 64k connections is assuming that
all IP addresses on a machine have the same connectivity and policy.
I can think of several cases where this is not true:
  1. Server machine with public IP's for connections and private IP's
     for backend database connection
  2. Applications where certain IP's are required for security
     protocols
  3. Machines doing policy based routing

Doesn't this patch change/break this?
