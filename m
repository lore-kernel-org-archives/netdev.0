From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: take care of truncations done by sk_filter()
Date: Thu, 10 Nov 2016 13:04:34 -0800
Message-ID: <1478811874.8455.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1623420310.11961160.1478789246631.JavaMail.zimbra@redhat.com>
         <1478792652.8455.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478805992.8455.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478811016.8455.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Marco Grassi <marco.gra@gmail.com>
To: Vladis Dronov <vdronov@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35252 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932614AbcKJVEg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 16:04:36 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so5344348pfk.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 13:04:36 -0800 (PST)
In-Reply-To: <1478811016.8455.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-10 at 12:50 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> With syzkaller help, Marco Grassi found a bug in TCP stack,
> crashing in tcp_collapse()


I will send a v2, we need to reload iph, not only th.
