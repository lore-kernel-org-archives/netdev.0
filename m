From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge updates
Date: Wed, 21 Feb 2007 18:04:12 +0100
Message-ID: <45DC7B8C.9070501@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1930 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030363AbXBURY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 12:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

No big change in myri10ge these days, mainly just a workaround for
boards that were shipped with a bug in their firmware (patch #1, for
2.6.21).

Since things are pretty calm here, I am also resending the Large Receive
Offload patch for inclusion (patch #2, maybe only for 2.6.22?). I didn't
hear of anybody working on a generic LRO for the core stack, while our
driver performance suffered from missing LRO for several months already.
The code has been intensively tested by multiple customers.

Thanks,
Brice

