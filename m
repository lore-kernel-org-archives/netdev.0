From: Jeff Silverman <jeffsilverm@gmail.com>
Subject: I find one aspect of the ip link show command confusing and I'd like
 you to fix it, please
Date: Sun, 23 Apr 2017 15:36:32 -0700
Message-ID: <CAGu9dLLRVaiO-vHd_jzVuMM3O=sjLX_VOeu5n6-+eV6fEdhBug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:34026 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756898AbdDWWge (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 18:36:34 -0400
Received: by mail-qt0-f169.google.com with SMTP id c45so101271244qtb.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 15:36:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

People,

When my NIC is up, but not connected, I see:

root@jeff-desktop:~# ip link show enp3s0
2: enp3s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state
DOWN mode DEFAULT group default qlen 1000
    link/ether 00:10:18:cc:9c:77 brd ff:ff:ff:ff:ff:ff
root@jeff-desktop:~# ip link show enp3s0

NO-CARRIER makes sense to me - if the wire is unplugged, then the NIC
isn't seeing the humm at the beginning of each packet.  That's clear.
Note that even though my link isn't plugged in,  ip still notes that
it is up.  That's great.


But if I down my NIC, there is no indication that it is DOWN other
than you can't see the UP flag.  If somebody was new to linux, they
would not see what's not there.

2: enp3s0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN mode
DEFAULT group default qlen 1000
    link/ether 00:10:18:cc:9c:77 brd ff:ff:ff:ff:ff:ff


What I would like you to do is modify the ip command so that if the
NIC has been downed by something, then it explicitly says DOWN.

What would be really nice would be if you enumerated all of the flags
that an interface can have, and note if the flag is set or cleared.
But that's more than what I want with this message.


Many thanks,


Jeff

-- 
Jeff Silverman, linux sysadmin
nine two four   twentieth avenue east
Seattle, WA, nine eight one one two -3507
(253) 459-2318
jeffsilverm@gmail.c0m (note the zero!)
http://www.commercialventvac.com
See my portfolio of writings and talks
