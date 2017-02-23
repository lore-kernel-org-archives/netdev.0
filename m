From: Paolo Minazzi <paolo.minazzi@gmail.com>
Subject: Software loopback with phy 88E1116R and marvell MV78100 gbe
Date: Thu, 23 Feb 2017 09:42:25 +0100
Message-ID: <CABmfJQYEqWzPtfieaym-4KhG5f0PBHNDQzuT0Uk_bz-2WC3zag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f182.google.com ([74.125.82.182]:35414 "EHLO
        mail-ot0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751170AbdBWInH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 03:43:07 -0500
Received: by mail-ot0-f182.google.com with SMTP id w44so19436925otw.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 00:42:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi to all,
I have written a low level driver for MV78100 arm board.
All works well.
I have built a physical loopback cable to cross rx and tx to test my
driver and all is good.

I have an other board (with imx6).
On this board I was able to put the PHY (micrel) in loopback mode, so
I do not need a physycal loop. All works well.

I tried to do the same things on 88E1116R, setting the but 14 of reg 0.
But If I do it I lose the link, and the test program does not work.
I tried to force the link in software, but seems the controller send
packets but it is not able to receive them.
Is possibile to do such a software loopback on 88E1116R ?

Thanks in advance,
Paolo Minazzi
