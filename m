From: Andrew Morton <akpm@linux-foundation.org>
Subject: net driver error accounting
Date: Thu, 2 Aug 2007 13:17:18 -0700
Message-ID: <20070802131718.84543097.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Natalie Protasevich <protasnb@gmail.com>
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40247 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754943AbXHBUSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 16:18:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Looking at http://bugzilla.kernel.org/show_bug.cgi?id=8106

Guys, could we please have a ruling here?

When a net driver encounters a tx_fifo_error, should this also contribute
to the tx_error count, or should it not?

More generally, should netdev drivers accumulate all the detailed
rx_errors into net_device_stats.rx_errors in real time, or should they not?

Thanks.
