From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/4] Checksum fixes
Date: Thu, 12 Jun 2014 16:02:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121554310.30089@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:54222 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaFLXCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:02:53 -0400
Received: by mail-ie0-f201.google.com with SMTP id lx4so407994iec.2
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:02:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes related to some recent checksum modifications.

- Fix logic in saving checksums complete in __skb_checksum_complete
- Call __skb_checksum_complete from UDP if we are checksumming over
  whole packet in order to save checksum.
- Fixes to VXLAN to work correctly with checksum complete
