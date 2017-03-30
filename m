From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: avoid dirtying sk_stamp, if possible
Date: Thu, 30 Mar 2017 08:37:50 -0700
Message-ID: <1490888270.24891.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
         <1490881940.24891.66.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490883829.2616.18.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34547 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933970AbdC3Phy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 11:37:54 -0400
Received: by mail-pg0-f51.google.com with SMTP id 21so43422930pgg.1
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 08:37:54 -0700 (PDT)
In-Reply-To: <1490883829.2616.18.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 16:23 +0200, Paolo Abeni wrote:

> That way, if the net timestamp is enable, we will record the timestamp
> of the first packet received by the socket (it can be far away in the
> past).
> I think is just a different kind of approximation.

I see.

This (64bit) sk_stamp stuff is quite buggy on 32bit kernels anyway.

Acked-by: Eric Dumazet <edumazet@google.com>
