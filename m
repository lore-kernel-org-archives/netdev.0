From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: IGMP snooping problem
Date: Tue, 25 Sep 2012 10:59:08 +0800
Message-ID: <CAF1ivSbGo20rUdRa3tEDv+v8iDWpdH+1e-vunLx4oC+4iwSASw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: networking <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:50168 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab2IYDAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 23:00:10 -0400
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 9B9FCDBCBC
	for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 10:59:11 +0800 (CST)
Received: by lbbgj3 with SMTP id gj3so7706789lbb.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 19:59:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm testing IGMP snooping on a router which has 4 LAN ports.

# brctl show
bridge name     bridge id                      STP enabled     interfaces
br0                  8000.00037fbef050       yes                   eth0

          eth1

          eth2

          eth3

          ath0

          ath1

          ath2

          ath3

ath0, 1, 2, 3 are WIFI.
IGMP snooping works well with this configuration.

The router supports a "switch mode", namely the 4 LAN ports connected
to a on-board switch.
In this mode, there is only a eth0, no eth1,2,3.
One benefit of this mode is that the traffic between LAN ports don't
need to go to CPU.
The LAN ports traffic will be handled by hardware switch directly.

# brctl show
bridge name     bridge id                      STP enabled     interfaces
br0                  8000.00037fbef050       yes                   eth0

          ath0

          ath1

          ath2

          ath3

In this mode, the IGMP snooping among the 4 LAN ports won't work.

Any idea how to resolve this problem?

Thanks,
Lin Ming
