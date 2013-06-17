From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/3] vxlan: stability patches
Date: Mon, 17 Jun 2013 12:09:56 -0700
Message-ID: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33903 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab3FQTKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 15:10:05 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so3163680pad.32
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 12:10:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No change to the content of any of these patches,
the only change is the order of which patches are in which bundle
and the base (these are for -net).

Stephen Hemminger (3):
  vxlan: fix race between flush and incoming learning
  vxlan: only migrate dynamic FDB entries
  vxlan: handle skb_clone failure

 drivers/net/vxlan.c |   40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

-- 
1.7.10.4
