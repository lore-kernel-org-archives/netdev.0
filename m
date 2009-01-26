From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/2 2.6.30] cxgb3 - notify iWARP of chip resets
Date: Mon, 26 Jan 2009 09:42:33 -0800
Message-ID: <497DF609.9000600@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:5778 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752000AbZAZRm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:42:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Roland,

I'm submitting 2 patches against cxgb3 and iw_cxgb3 respectively.
They are built against net-next-2.6.
The first patch adds a notification mechanism to cxgb3 to alert
the upper layer drivers (iWARP and iSCSI) of a chip reset.

The second patch adds the handler for such an event in the iWARP driver.

Since the second patch depends on the first one, I submit them together,
even though the second patch should be submitted against Roland's tree.

Cheers,
Divy

