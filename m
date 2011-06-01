From: Joe Perches <joe@perches.com>
Subject: [RFC] Moving files around in drivers/net
Date: Wed, 01 Jun 2011 12:30:02 -0700
Message-ID: <1306956602.32125.28.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2396 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756771Ab1FATaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 15:30:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone still think moving files around in drivers/net
would be sensible and a suitable candidate for inclusion
in 3.1?

Here's what Jeffrey proposed:
http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf

Here's what I proposed before that.
http://www.spinics.net/lists/netdev/msg149717.html

I agree with Jan that the current 10/100, 1000, 10000 speed
selections mechanisms are less than ideal.

Perhaps it'd be worthwhile to remove that speed distinction.

