From: Guan Xin <guanx.bac@gmail.com>
Subject: ping: What's the purpose of rate limit?
Date: Sat, 31 Dec 2016 13:04:39 +0100
Message-ID: <CANeMGR4=vycxBU+LcrL2JXHt2FTYBkU2aLxfY5XRzHdws-aYag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33954 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753736AbcLaMFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2016 07:05:21 -0500
Received: by mail-wm0-f51.google.com with SMTP id u144so89851534wmu.1
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2016 04:05:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Excuse me, I searched but didn't find an answer --

What's the purpose of setting a limit to the "-i" and "-l" parameters
of ping for non-root users?

It seems that this is only intended to prevent accidental misuse
because these restrictions can be easily worked around by starting
multiple instances or wrapping the program in a loop, e.g.,
while true; do ping -l3 -c3 192.168.0.1; done

(Please Cc to me because I'm not subscribed to this list. Thanks!)

Regards,
Guan
