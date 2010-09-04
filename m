From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: rps: add the shortcut for one rps_cpus
Date: Sat, 4 Sep 2010 20:18:20 +0800
Message-ID: <AANLkTik8EXfzTzJGBu9pQKQUO6WQM9p1gmr64vkQjA64@mail.gmail.com>
References: <1283591557-31921-1-git-send-email-xiaosuo@gmail.com> <1283598071.3402.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41562 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab0IDMSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 08:18:41 -0400
Received: by wyf22 with SMTP id 22so1029703wyf.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 05:18:40 -0700 (PDT)
In-Reply-To: <1283598071.3402.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 4, 2010 at 7:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> You are 'optimizing' a very unusual case and slow down 99% of normal
> uses.
>
> Normal way to handle this, is to use irq affinity and deliver interrupts
> directly to the target cpu.
>
>

Some pseudo network devices may share the same interrupt, such as vlan
network devices. In this case, setting the IRQ affinity can't work.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
