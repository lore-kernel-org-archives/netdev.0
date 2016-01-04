From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/3] nfp: MTU changes and other fixes
Date: Mon,  4 Jan 2016 16:03:12 +0000
Message-ID: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33653 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcADQDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:03:23 -0500
Received: by mail-wm0-f41.google.com with SMTP id f206so178562529wmf.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 08:03:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Three small fixes around RX buffer sizing.  First one corrects
the length used for unmapping DMA buffers when MTU is changed,
second makes sure buffers are big enough to meet FW's expectations.
Third change corrects packet length validation on RX.


Jakub Kicinski (3):
  nfp: free buffers before changing MTU
  nfp: correct RX buffer length calculation
  nfp: fix RX buffer length validation

 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 37 +++++++++-------------
 1 file changed, 15 insertions(+), 22 deletions(-)

-- 
1.9.1
