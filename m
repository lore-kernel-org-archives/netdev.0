From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 8/8] tcp: tsq: move tsq_flags close to
 sk_wmem_alloc
Date: Sat, 03 Dec 2016 17:13:51 -0800
Message-ID: <1480814031.18162.439.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
         <1480792497-16607-9-git-send-email-edumazet@google.com>
         <20161203.191626.976921736888291388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33754 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbcLDBNy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 20:13:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so12056758pgd.0
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 17:13:54 -0800 (PST)
In-Reply-To: <20161203.191626.976921736888291388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-12-03 at 19:16 -0500, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Sat,  3 Dec 2016 11:14:57 -0800
> 
> > diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> > index d8be083ab0b0..fc5848dad7a4 100644
> > --- a/include/linux/tcp.h
> > +++ b/include/linux/tcp.h
> > @@ -186,7 +186,6 @@ struct tcp_sock {
> >  	u32	tsoffset;	/* timestamp offset */
> >  
> >  	struct list_head tsq_node; /* anchor in tsq_tasklet.head list */
> > -	unsigned long	tsq_flags;
> >  
> >  	/* Data for direct copy to user */
> >  	struct {
> 
> Hmmm, did you forget to "git add include/net/sock.h" before making
> this commit?

sk_tsq_flags was added in prior patch in the series ( 7/8 net:
reorganize struct sock for better data locality)

What is the problem with this part ?

Thanks
