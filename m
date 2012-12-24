From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Patch] arp: fix a regression in arp_solicit()
Date: Mon, 24 Dec 2012 02:33:21 +0100
Message-ID: <CA+icZUX4W0zAbxJOO1di4Y1-f4w=h4WUVS7tfCLvkRG+Muc61g@mail.gmail.com>
References: <1356273778-19113-1-git-send-email-xiyou.wangcong@gmail.com>
	<CA+icZUWKNAGe+jMbsonrigVZ5Sk7dDdciZn1r7oMcsAWe7i3fQ@mail.gmail.com>
	<CA+icZUXo+OQ4XZ8V588FHKrDanqwq8jR1pAHwVPjJcu+14TKeQ@mail.gmail.com>
	<20121223.141706.1783471119472317669.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:50231 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab2LXBdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 20:33:21 -0500
Received: by mail-qc0-f169.google.com with SMTP id t2so3560103qcq.28
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 17:33:21 -0800 (PST)
In-Reply-To: <20121223.141706.1783471119472317669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 23, 2012 at 11:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Sedat Dilek <sedat.dilek@gmail.com>
> Date: Sun, 23 Dec 2012 15:58:52 +0100
>
>> While at it you might enhance the label with "ipv4"?
>
> That's excessive.
>
> ARP is ipv4 and ipv4 only, in other protocols it has completely
> different names.

OK, I see (shorter subject is always good).
I oriented myself at the original commit from Eric which was labeled the same.
Just had a look at the git-history [1] myself...

- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=history;f=net/ipv4/arp.c
