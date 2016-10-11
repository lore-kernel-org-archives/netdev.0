From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: saddr based blackhole/unreachable route
Date: Tue, 11 Oct 2016 20:39:49 +0200
Message-ID: <CAJO99Tn7oaGEhRKEBR83K_+JSJUaFXEqvMnbM3vOLVxDqF9wtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:36147 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbcJKStE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 14:49:04 -0400
Received: by mail-yw0-f171.google.com with SMTP id u124so19167710ywg.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 11:47:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, netdev

In a typical setup (eth0=internet, eth1=lan) i populate routing table
100 with saddrs I want
dropped, and: "ip ru a pref 100 lookup table 100"

What I would expect to see is packets with a saddr in table 100 coming
in eth0 will go out eth1,
with replies beeing dropped, but I do not see the packets going out eth1 at all.

Have tried searching and following the fib codepath, but have still
not managed to understand
what is really going on here.

Is the saddr looked up in the routing table?
Why dont I get icmp unreachable for unreachable routes?
Is tcpdump tricking me here?

I like the behavior, I just don't know if I can trust it.

Kernel 4.8.1

Regards,
-- 
Bj(/)rnar
