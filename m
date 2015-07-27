From: s prasad <sprasad.kandregula@gmail.com>
Subject: Need help about AR8327 Ethernet Driver
Date: Mon, 27 Jul 2015 12:16:10 -0400
Message-ID: <CAJa-X96OijRZS4G5eKRUR0c3QG8zpYVJj53t68m_z3O1fgf8Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mathieu Olivari <mathieu@codeaurora.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f50.google.com ([209.85.216.50]:36242 "EHLO
	mail-vn0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbbG0QQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 12:16:12 -0400
Received: by vnk197 with SMTP id 197so32664369vnk.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 09:16:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi  All,

I am trying to sniff Ethernet data using AR8327 chip-set from other
Ethernet device KSZ8895, which gives multiplexed TX and RX data of
monitoring data of another device.

If I am using devices like DUB-E100(D-Link), am able capture data from
KSZ8895(Multiplexed TX and Rx Ethernet data).

But If I am trying to sniff Ethernet data using AR8327 Chipset(Router
TP-Link AC 1750), then am not able to capture data. But in
(switch/port) port registers showing correct values.

Am using tcpdump to check data on specific interface. When I am using
DUB-E100(D-Link) or passive Ethernet sniffer(Either Rx or Tx packets)
then able to see whole data, but not with AR8327 Chipset.

My environment is given below:
Router: TPLink AC 1750
Ethernet data coming from KSZ8895 (Multiplexed Tx and RX of another device)
"OpenWRT" Environment

Can somebody through where should I look to solve my issue.

Thanks and Regards,
S Prasad
