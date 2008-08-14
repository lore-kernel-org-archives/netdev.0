From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 0/2] netns: fix for NULL-dereference in ipv6 code
Date: Thu, 14 Aug 2008 15:27:19 -0400
Message-ID: <48A48717.4020609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:26210 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbYHNT1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 15:27:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When fixing the NULL-dereference of the idev in rt6_fill_node(), I
noticed that dev_net() doesn't handle a NULL argument either.  These two
patches fix that, as well as add a network namespace argument to
rt6_fill_node() and ipv6_dev_get_saddr().

-Brian

