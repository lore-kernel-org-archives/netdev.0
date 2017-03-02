From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/2] nfp: RX and XDP buffer fixes
Date: Thu,  2 Mar 2017 15:26:19 -0800
Message-ID: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35809 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdCCFcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 00:32:13 -0500
Received: by mail-pf0-f171.google.com with SMTP id j5so29734011pfb.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 21:31:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Two trivial fixes for code introduced with XDP support.  First
one corrects the buffer size we populate a register with.  The
register is designed to be used for scatter transfers which 
the driver (and most FWs) don't support so it's not critical.
The other one for DMA direction is mostly cosmetic, DMA API
doesn't seem to care today about the precise direction in sync
calls.

Jakub Kicinski (2):
  nfp: don't tell FW about the reserved buffer space
  nfp: correct DMA direction in XDP DMA sync

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

-- 
2.11.0
