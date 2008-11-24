From: nik-lists@varna.net
Subject: e1000 and PBA
Date: Mon, 24 Nov 2008 17:28:49 +0200 (EET)
Message-ID: <1d380c73ba9296d4277c279e9808e84a.webmail@www.varna.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=windows-1251
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.Varna.Net ([217.145.80.1]:59767 "EHLO ns.varna.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693AbYKXPuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 10:50:19 -0500
Received: from www.varna.net (mail2.Varna.Net [217.145.80.3])
	by ns.varna.net (8.13.6/8.13.6) with ESMTP id mAOFSne1022150
	for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 17:28:49 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am experiencing rx_missed_errors with Intel 82541 based gige and e1000
8.0.6  on 32Bbit 33MHz PCI. In my opinion, the network load is not so
heavy - 15 kpps and 90 Mbit/s at peaktimes. CPU load is no more than 30%.
I know it is old hardware (Athlon@1725), but sill, it should be able to
handle this amount of traffic - here is no shaping, and there is hardly
any firewall rules. After lot of reading in maillists and forums, my
conclusion is that the bottleneck is in the RX FIFO buffers. Therefore, I
want to try increasing the RX PBA size. How can I check how much is the
overall PBS, which is split for TX/RX buffers by the driver? According to
the source, PBA is read from the card registers in the e1000_reset
function. Can I check this value somehow with ethtool ? Maybe after I know
how much PBS is available, I will be able to calculate how much RX FIFO
will be left if I need only 4K TX FIFO (pretty enough for full wire-speed
transmitting according to the tdriver source).

Thank you very much in advance.


