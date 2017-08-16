From: Robert Jones <rjones@gateworks.com>
Subject: Stuck TX Using Iperf
Date: Wed, 16 Aug 2017 10:46:53 -0700
Message-ID: <CALAE=UDTbr8u0kPcEA3mLL+CMBxUOexvON8tdV2QxKyCeHFwRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tim Harvey <tharvey@gateworks.com>
To: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36602 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdHPRqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:46:54 -0400
Received: by mail-qk0-f177.google.com with SMTP id o124so15715957qke.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 10:46:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Cavium Ethernet Driver Maintainers,

I'm working on a custom board using a Cavium OcteonTX CN80XX cpu
running a mainline 4.12.7 kernel and I've run into a problem where the
TX of my BGX0 configured for SGMII becomes stuck.

After boot I'm able to bring the interface up, run dhclient, and ping
a host machine with no issues. However, every time that I try to run
an iperf TCP test I get a stuck TX queue. Bringing the interface down
and then up does not resolve the problem, but physically reconnecting
the cable connected to the interface does. Also, after I reconnect the
cable I am no longer able to reproduce the stuck TX queue until
reboot. I receive no kernel driver messages of any sort during my
iperf test, it just stalls until I kill it.

Any help would be appreciated.

Regards,

Robert Jones - Software Engineer
Gateworks Corporation
