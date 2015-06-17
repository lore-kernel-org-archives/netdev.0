From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: macb napi strange behavior
Date: Wed, 17 Jun 2015 19:09:34 +0300
Message-ID: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35090 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482AbbFQQJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 12:09:36 -0400
Received: by lbbwc1 with SMTP id wc1so35041482lbb.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 09:09:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm trying to determine why I have a huge number of IRQs for only a
macb interface and the other one works just fine (low IRQ activity). I
have activated IP forward and I'm just forwarding packets from eth0 to
eth1.
The platform is Zynq7, Linux kernel 4.0, vanilla macb.

cat /proc/interrupts:
[...]
144:     679425     0       GIC  54  eth0
145:   17867097          0       GIC  77  eth1
[...]

Any ideas?

Best regards,
Nicolae Rosia
