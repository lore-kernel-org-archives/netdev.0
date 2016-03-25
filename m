From: vincent Richard <vincent.richard449@gmail.com>
Subject: tg3 link autoneg on one port results in packets loss on other port
Date: Fri, 25 Mar 2016 12:41:01 +0100
Message-ID: <CABVbdp__Rj=Si8EFazOD-gctgcs30gWB3Q8J9wqSLcKfio5HyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37404 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcCYLlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 07:41:02 -0400
Received: by mail-ig0-f171.google.com with SMTP id l20so11821407igf.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 04:41:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I am using a HP DL360p server with broadcom BCM5719 ethernet card
handled by tg3 driver.
When the link is renegotiated on one ethernet port, out packets get
lost on other ethernet ports. The problem is easily reproducible by
looping on switch port up/down.
Instrumenting the driver, I observed that tg3_setup_phy() may last
more than 40 msec while holding the spin lock.
Is it possible to modify the tg3 driver so as to minimize link
renegotiation  impact ?
Thanks in advance for your help.
