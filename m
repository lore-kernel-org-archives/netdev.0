From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 0/3] Series short description
Date: Wed, 01 Apr 2009 00:16:46 -0600
Message-ID: <20090401060117.8641.32252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:40614 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbZDAGQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 02:16:54 -0400
Received: by rv-out-0506.google.com with SMTP id g37so2033836rvb.5
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 23:16:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Here are the fec_mpc52xx patches which should be picked up for 2.6.29.
Patch #1 fixes a dma related BUG_ON() discovered after the merge window
opened.  #2 & #3 were original a single patch posted prior to the merge
window, but not having a s-o-b line from the original author held them up.
In the end I rewrote it from scratch as two patches just so I can get
them merged.  #2 makes the driver use net_device_ops, and #3 fixes a NULL
dereference.

I've tested these patches on several MPC5200 platforms.

 drivers/net/fec_mpc52xx.c |   77 +++++++++++++++++++++++++-------------------
 1 files changed, 44 insertions(+), 33 deletions(-)

Cheers,
g.

--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
