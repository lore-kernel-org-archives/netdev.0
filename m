From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5] qla3xxx:resubmit support for Qlogic 4032 and fixes.
Date: Tue, 19 Dec 2006 10:18:55 -0800
Message-ID: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53404 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932886AbWLSSdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 13:33:06 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These 5 patches were submitted on Dec 5th (1&2) and Dec 11th (3-5).  They add/fix the following

1. Add support for Qlogic 4032 chip.
2. Change minor version for 4032 support.
3. Add delay when accessing NVRAM.
4. Remove NETIF_F_LLTX flag from features.  It was left over from the early driver and shouldn't be there.
5. Fix rx checksum warning.

We didn't get any feedback on any of these previously posted patches and couldn't find a tree where they were added.  We've build and tested them on 2.6.20-rc1.

These patches must be applied in order.

