From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] net: ubuf_info.refcnt conversion
Date: Fri, 01 Sep 2017 10:36:29 -0700
Message-ID: <1504287389.15310.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831234822.26612-1-edumazet@google.com>
         <1504224295.15310.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36244 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdIARgb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:36:31 -0400
Received: by mail-pf0-f194.google.com with SMTP id k3so500453pfc.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 10:36:31 -0700 (PDT)
In-Reply-To: <1504224295.15310.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 17:04 -0700, Eric Dumazet wrote:
> On Thu, 2017-08-31 at 16:48 -0700, Eric Dumazet wrote:
> > Yet another atomic_t -> refcount_t conversion, split in two patches.
> > 
> > First patch prepares the automatic conversion done in the second patch.
> > 
> > Eric Dumazet (2):
> >   net: prepare (struct ubuf_info)->refcnt conversion
> >   net: convert (struct ubuf_info)->refcnt to refcount_t
> > 
> >  drivers/vhost/net.c    |  2 +-
> >  include/linux/skbuff.h |  5 +++--
> >  net/core/skbuff.c      | 14 ++++----------
> >  net/ipv4/tcp.c         |  2 --
> >  4 files changed, 8 insertions(+), 15 deletions(-)
> > 
> 
> David please ignore this series, I will send a V3 :)
> 

No need for a V3, sorry for the confusion, but we had to double check
with Willem that everything had been covered.

Please tell me if I need to resend, thanks !
