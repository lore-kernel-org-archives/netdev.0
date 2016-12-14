From: Eric Desrochers <eric.desrochers@canonical.com>
Subject: netfilter -stable backport request
Date: Wed, 14 Dec 2016 10:35:27 -0500
Message-ID: <4772c78b-8a6e-4be3-2065-02292c87f6ae@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: stable@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35300 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755846AbcLNPf3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 10:35:29 -0500
Received: by mail-io0-f175.google.com with SMTP id h30so43089060iod.2
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 07:35:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to request a -stable backport for the following patchset that as we speak can be found in pablo's nf-next:

# git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

[PATCH 1/3]
commit 2394ae21e8b652aff0db1c02e946243c1e2f5edb
netfilter: x_tables: pass xt_counters struct instead of packet counter
   
[PATCH 2/3]
commit 18b61e8161cc308cbfd06d2e2c6c0758dfd925ef
netfilter: x_tables: pass xt_counters struct to counter allocator

[PATCH 3/3]
commit 722d6785e3b29a3b9f95c4d77542a1416094786a
netfilter: x_tables: pack percpu counter allocations

Please add this to stable branches : v4.4.x, v4.8.x

The above patchset is fixing a netfilter regression which introduced a performance slowdown in binary arp/ip/ip6tables starting at commit :

#v4.2-rc1
commit 71ae0dff02d756e4d2ca710b79f2ff5390029a5f
netfilter: xtables: use percpu rule counters

Regards,

Eric
