From: Simon Chen <simonchennj@gmail.com>
Subject: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 18:44:43 -0500
Message-ID: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56371 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab1KPXop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 18:44:45 -0500
Received: by fagn18 with SMTP id n18so2216198fag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 15:44:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am bonding two 10G interfaces (ixgbe driver) under Debian 6.0.2. The
bonded interface for some reason can only achieve 12Gbps aggregated
throughput. If a single NIC is used, I can get close to 10Gbps.

I've tried different bonding modes (balance-xor, 802.3ad, balance-alb,
balance-tlb), and different xmit hashing policy (layer2, layer2+3,
layer3+4). I've increased all types of kernel parameters for TCP. MTU
on the physical and bonded interface is set to 8000 and 9000. The MTU
on the switch is 9200+.

Instead of nperf (a single server), I also tried my own TCP sender and
receivers.

All those done, still only 12Gbps... How can I really achieve close to 20Gbps?

(I also tried cutting loose the switch in between, and also getting
12G, so not an issue with the switch.)

Thanks.
-Simon
