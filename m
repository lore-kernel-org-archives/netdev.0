From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Sat, 12 Apr 2014 12:32:52 -0700
Message-ID: <1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	 <1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	 <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chptx y <chptxy@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:49350 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbaDLTcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 15:32:53 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so6719984pbc.34
        for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 12:32:53 -0700 (PDT)
In-Reply-To: <CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-04-12 at 12:35 -0600, Sharat Masetty wrote:
> Check /proc/net/netstat and /proc/net/snmp
> 
> In netstat look for
> 
> LINUX_MIB_TCPOFODROP and LINUX_MIB_BACKLOGDROP

The packet is not out of order, according to tcpdump.

Note that the receiver reacts to incoming packet, sending a DUPACK, so
its not a backlogdrop.

tcpdump trace is really incomplete, I asked tcpdump -vv but got nothing
from chptx, assuming this is a real name.

packet might be rejected because of a zero receiver window, who knows.

I might search in my basement this crystal ball I might have.
