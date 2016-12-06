From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Tue, 06 Dec 2016 06:35:56 -0800
Message-ID: <1481034956.18162.578.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481017989.6225.21.camel@redhat.com> <1481026212.6225.43.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32901 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbcLFOf7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 09:35:59 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so18847349pfv.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 06:35:58 -0800 (PST)
In-Reply-To: <1481026212.6225.43.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-06 at 13:10 +0100, Paolo Abeni wrote:

> Please ignore the above dumb comment. I misread the 'skip condition'.
> 
> I'm fine with the patch in its current form.
> 
> Acked-by: Paolo Abeni <pabeni@redhat.com>

No worries, I prefer having multiple eyes on this stuff before doing the
next step ;)

Thanks !
