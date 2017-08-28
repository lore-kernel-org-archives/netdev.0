From: Bassam Alsanie <bassam.alsanie@gmail.com>
Subject: Get ARP/ND tables from kernel
Date: Sun, 27 Aug 2017 18:25:37 -0700
Message-ID: <CAJW__LkW10SWRmEKP_0YxjbVHjUYqJFPKsKn-52D1ucF+HH9uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35595 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbdH1BZj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 21:25:39 -0400
Received: by mail-qk0-f169.google.com with SMTP id p67so19668704qkd.2
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2017 18:25:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,
I looking into a good way (stable and compatible with large number of
distros) to get the arp/nd cache from kernel to user space, for both
IP4 and IP6.

It seem IOCTL (SIOCGARP) can't do that, you can only get MAC address
from provided IP address. But IOCTL can't give the the full arp/nd
table.
The other option is the Netlink interface. I tried it and I got the
ARP/ND table :).
The third option is using /proc/net/arp, which only restricted to IP4.

There is command line utilities that I excluding in my case.

Is there another way to do it? what is the best way in my case?

Thank you all.
