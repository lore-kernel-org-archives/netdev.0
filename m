From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 0/5] Checksum fixes
Date: Sat, 14 Jun 2014 23:23:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406142312290.17261@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joseph.gasparakis@intel.com, geert@linux-m68k.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:54291 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbaFOGXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 02:23:46 -0400
Received: by mail-vc0-f202.google.com with SMTP id id10so538710vcb.1
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2014 23:23:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes related to some recent checksum modifications.

- Fix GSO constants to match NETIF flags
- Fix logic in saving checksum complete in __skb_checksum_complete
- Call __skb_checksum_complete from UDP if we are checksumming over
  whole packet in order to save checksum.
- Fixes to VXLAN to work correctly with checksum complete
