From: Daniel Nilsson <gnuffel@gmail.com>
Subject: using netif_rx while NAPI is used?
Date: Fri, 17 Aug 2012 14:24:59 +0200
Message-ID: <CAEXQUezURzFPQzfsao93cHDWGXB3TwxrMfJJYjLsfi+=HeO3Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59090 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751602Ab2HQMZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 08:25:01 -0400
Received: by lagy9 with SMTP id y9so2060737lag.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 05:25:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a special case (VPN router) where I sometimes need to bounce up
a packet (after being marked) that is impossible to transmit using the
netif_rx() callback. The interface normally uses NAPI and therefore is
polled in the RX direction. Will it still work to pass a small amount
of packets directly up to the kernel using the netif_rx() callback?

/Daniel
