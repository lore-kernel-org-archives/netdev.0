From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net 0/5] nfp: MTU fixes for net
Date: Thu, 18 Feb 2016 20:38:08 +0000
Message-ID: <1455827893-26366-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34544 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946394AbcBRUiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:38:18 -0500
Received: by mail-wm0-f41.google.com with SMTP id b205so41796467wmb.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 12:38:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave!

This is the first part of MTU reconfiguration fixes.  These
are the patches which I would like to get into -net.  The
requested overhaul of the way MTU configuration is done is
posted as a separate series targeted at net-next.

Thanks!


Jakub Kicinski (5):
  nfp: return error if MTU change fails
  nfp: free buffers before changing MTU
  nfp: correct RX buffer length calculation
  nfp: fix RX buffer length validation
  nfp: don't trust netif_running() in debug code

 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 42 ++++++++++------------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  4 +--
 2 files changed, 20 insertions(+), 26 deletions(-)

-- 
1.9.1
