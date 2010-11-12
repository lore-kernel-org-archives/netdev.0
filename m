From: Mark Ryden <markryde@gmail.com>
Subject: request_threaded_irq()
Date: Fri, 12 Nov 2010 14:27:11 +0200
Message-ID: <AANLkTikCQRiW3oWYSXK7yTxLWd3us+8wdwfuOs1k71VD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33827 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab0KLM1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 07:27:12 -0500
Received: by fxm6 with SMTP id 6so37700fxm.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 04:27:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

grepping under net-next-2.6/drivers/net for request_threaded_irq() ,
shows that it appears only in 3 drivers:

can/mcp251x.c
wireless/b43/main.c
wireless/rt2x00/rt2x00pci.c

I was wondering: when thinking about performance, is it worthwhile to use this
API instead of ordinary request_irq() . It seems to me that
request_threaded_irq()  might
be better in some cases than NAPI polling forr network drivers (or at
list it might be so in some systems, maybe multicore ?)


Best,
Mark Ryden
