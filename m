From: Harsha Chenji <cjkernel@gmail.com>
Subject: net.ipv4.tcp_max_syn_backlog implementation
Date: Mon, 28 Aug 2017 23:47:41 -0400
Message-ID: <CAMB9Wx+q9fidTnh3Tyias8KKdbRcKpoXM-ntSqjE_oW36F1W_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:38242 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdH2Drm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 23:47:42 -0400
Received: by mail-io0-f180.google.com with SMTP id 81so11729629ioj.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 20:47:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I have ubuntu 12.04 x32 in a VM with syncookies turned off. I tried
to do a syn flood (with netwox) on 3 different processes. Each of them
returns a different value with netstat -na | grep -c RECV :

nc -l 5555 returns 16 (netcat-traditional)
apache2 port 80 returns 256
vsftpd on 21 returns 64.
net.ipv4.tcp_max_syn_backlog is 512.

Why do these different processes on different ports have different
queue lengths for incomplete connections? Where exactly in the kernel
is this decided?
