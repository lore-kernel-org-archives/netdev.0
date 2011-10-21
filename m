From: fengcheng lu <sparking.lu@gmail.com>
Subject: Questions about CHECKSUM_COMPLETE
Date: Thu, 20 Oct 2011 23:05:25 -0400
Message-ID: <CAF5V5FbthBZ3QFzCUVov8MZ9TgF=+B6XM3eR+cyizbzcT-6v-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51706 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab1JUDF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 23:05:26 -0400
Received: by bkbzt19 with SMTP id zt19so4297623bkb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 20:05:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone

I have one question about the CHECKSUM_COMPLETE. When
CHECK_SUM_COMPLETE is set, which data does the skb->csum computed by
hardware cover?

I thought skb->csum only covers the Transport header (e.g. TCP/UDP) +
Transport payload + pseudo header. However, after I read the vlan
codes (vlan_skb_recv in the vlan_dev.c of linux kernel 2.6.27.19), I
become confuse.

The vlan_skb_recv calls skb_pull_rcsum which updates the skb->csum if
CHECKSUM_COMPLETE is set. It implies the vlan  header is also covered
by the skb->csum. so I wonder if the skb->csum cover the whole data
besides the eth header (14 bytes).

Thanks
Steven Lu
