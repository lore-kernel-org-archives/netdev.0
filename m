From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iproute2: ss: escape all null bytes in abstract unix
 domain socket
Date: Fri, 02 Dec 2016 15:24:35 -0800
Message-ID: <1480721075.18162.389.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
         <20161112101729.4d400929@samsung9>
            <1480705196.18162.381.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161202151810.4fab9504@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Isaac Boukris <iboukris@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36744 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750903AbcLBX0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:26:33 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so9170138pgx.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:25:36 -0800 (PST)
In-Reply-To: <20161202151810.4fab9504@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 15:18 -0800, Stephen Hemminger wrote:
>                                     name[i] = '@';
> > 
> > ss.c: In function 'unix_show_sock':
> > ss.c:3128:4: error: 'for' loop initial declarations are only allowed in C99 mode
> > ss.c:3128:4: note: use option -std=c99 or -std=gnu99 to compile your code
> > make[1]: *** [ss.o] Error 1
> > 
> > 
> > 
> 
> Thanks, fixed by patch from Simon

Right, thanks !
