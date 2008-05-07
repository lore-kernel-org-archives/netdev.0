From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/2 2.6.26] cxgb3 - EEH fixes
Date: Tue, 06 May 2008 19:25:53 -0700
Message-ID: <48211331.8010400@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28306 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727AbYEGCje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 22:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

I'm submitting a patch series for inclusion in 2.6.26.
The patches are built against Linus'tree.

The first patch fixes the error path if EEH does not recover the adapter.
The second patch guarantees that the chip is reset when EEh detects a 
pci error,
and fixes the recovery.

Cheers,
Divy
