From: Tom Herbert <therbert@google.com>
Subject: Does CHECKSUM_COMPLETE work at all?
Date: Fri, 21 Feb 2014 18:11:30 -0800
Message-ID: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:64536 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbaBVCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 21:11:31 -0500
Received: by mail-ig0-f170.google.com with SMTP id t19so16612igi.1
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 18:11:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a driver sets CHECKSUM_COMPLETE in a packet, I don't see anywhere
in either the Ethernet rcv path or ip_rcv where the skb->csum is being
pulled (no *pull_rcsum calls). I believe CHECKSUM_COMPLETE means the
checksum is over the whole packet (L2, L3, and L4), so it looks like
TCP would never see a usable value.

Is this interpretation correct? There's only a handful of drivers
providing CHECKSUM_COMPLETE can anyone who has access verify this?

Thanks,
Tom
