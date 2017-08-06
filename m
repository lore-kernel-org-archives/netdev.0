From: Rafael Cepeda <rcepeda1993@gmail.com>
Subject: NULL pointer deref bring up interfaces
Date: Sun, 6 Aug 2017 12:29:13 -0500
Message-ID: <CAEMnpcuw8Ow37_amPQtm66EkLwEpTDHWQFoe5UmFXzczYeQ-1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36657 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdHFR3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 13:29:15 -0400
Received: by mail-wm0-f41.google.com with SMTP id t201so52731220wmt.1
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 10:29:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just upgraded to 4.13rc2, rebooted, and my system crashed at my
netmount init script; says RIP is NULL, I am guessing a bad func call.
I immediately thought missing firmware in kernel, my kernel builds
firmware in it, so I upgraded my firmware to latest on git.kernel and
made sure I had no warnings in dmesg about missing firmware. Still, I
receive this NULL pointer in the IP. If I disable my netmount on boot,
I can login, but can not bring up my interfaces, still get a RIP err
in kernel logs and cpu load sky-rockets...the issue still exists on
rc3.

Linux-Regression-ID: lr#084be9

I am willing to help and provide as much info as possible, thank you.
