From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] bnx2x: bnx2x_set_pbd_csum() random accesses
Date: Tue, 19 Apr 2011 18:11:43 +0200
Message-ID: <1303229503.3480.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42156 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab1DSQLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 12:11:48 -0400
Received: by wya21 with SMTP id 21so4949493wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 09:11:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys

bnx2x_set_pbd_csum() / bnx2x_set_pbd_csum_e2() seem to read
tcp_hdrlen(skb) even for non TCP frames ?

Also, (skb_network_header(skb) - skb->data) is signed, so 
	(skb_network_header(skb) - skb->data) / 2 is a bit expensive...

Thanks


