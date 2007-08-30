From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.23 0/2] cxgb3 driver fixes
Date: Wed, 29 Aug 2007 19:14:59 -0700
Message-ID: <46D62823.5000504@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8685 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbXH3CPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 22:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I'm resubmitting the cxgb3 dev->priv issue.
I'm also submitting a patch fixing the engine microcode loading.

The first patch changes in both cxgb3 and iw_cxgb3 related to
the dev->priv issue.
The second patch allows the driver to load the engine microcode
at the right time - when a port is brought up as opposed to
the module getting loaded. It does a better job at logging
the loading activity, and loosen the strict version requirement
currently in place.

Cheers,
Divy

