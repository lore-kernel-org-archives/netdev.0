From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] ip: fix IP_CHECKSUM handling
Date: Tue, 21 Feb 2017 06:02:32 -0800
Message-ID: <1487685752.9415.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3274d7c98d7d5ea07058d8b73f987fc60b6e8b6c.1487612303.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Tom Herbert <tom@herbertland.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36094 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752623AbdBUOCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:02:36 -0500
Received: by mail-pg0-f65.google.com with SMTP id a123so15681327pgc.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 06:02:36 -0800 (PST)
In-Reply-To: <3274d7c98d7d5ea07058d8b73f987fc60b6e8b6c.1487612303.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-21 at 09:33 +0100, Paolo Abeni wrote:
> The skbs processed by ip_cmsg_recv() are not guaranteed to
> be linear e.g. when sending UDP packets over loopback with
> MSGMORE.
> Using csum_partial() on [potentially] the whole skb len
> is dangerous; instead be on the safe side and use skb_checksum().
> 
> Thanks to syzkaller team to detect the issue and provide the
> reproducer.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Paolo !
