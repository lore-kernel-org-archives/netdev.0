From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: NFCT writing localhost conntrack entries too
Date: Tue, 29 Aug 2017 15:53:28 +0530
Message-ID: <CAA5aLPhyBj=ZE1OPuDw-vKqpceHZ2r8EdPiSdW66V74ya_HCdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34692 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdH2KX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 06:23:29 -0400
Received: by mail-pf0-f181.google.com with SMTP id h75so9119241pfh.1
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 03:23:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With ulog/nflog, NFCT plugin, is it possible to not log entries with src ip
as 127.0.0.1

I can see following options in ulogd.conf
#accept_src_filter=192.168.1.0/24,1:2::/64 # source ip of connection
must belong to these networks
#accept_dst_filter=192.168.1.0/24 # destination ip of connection must
belong to these networks
#accept_proto_filter=tcp,sctp # layer 4 proto of connections


... but what I am looking for is like deny_src_filter.

Is it possible?
