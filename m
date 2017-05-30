From: Doug Anderson <dianders@chromium.org>
Subject: Suggest stable pick for nfnetlink_queue memory leak
Date: Tue, 30 May 2017 15:38:36 -0700
Message-ID: <CAD=FV=XVMiwPJUWpNnwGcCEz24j-7-mOn6Fe5eRxTjFA-FcU9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Brian Norris <briannorris@chromium.org>,
        Guenter Roeck <groeck@chromium.org>,
        liping.zhang@spreadtrum.com, pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38677 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751105AbdE3Wii (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 18:38:38 -0400
Received: by mail-wm0-f52.google.com with SMTP id e127so2385586wmg.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 15:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was running kmemleak on a kernel based on 4.4.64 and I noticed that
my memory leak was fixed by commit b18bcb0019cf ("netfilter:
nfnetlink_queue: fix memory leak when attach expectation
successfully").  It seems like perhaps this should go to linux-stable?
 It's not a huge leak, but the fix is simple.

It looks as if the leak has existed since commit bd0779370588
("netfilter: nfnetlink_queue: allow to attach expectations to
conntracks")

Thanks!

-Doug
