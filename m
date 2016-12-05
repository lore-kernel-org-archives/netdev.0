From: Isaac Boukris <iboukris@gmail.com>
Subject: Re: [PATCH] iproute2: ss: escape all null bytes in abstract unix
 domain socket
Date: Mon, 5 Dec 2016 07:38:25 +0200
Message-ID: <CAC-fF8Q77JiO_AQGLLaKZymcDS3EGF3BYp5w=wxijJkLJPUmEA@mail.gmail.com>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
 <20161112101729.4d400929@samsung9> <1480705196.18162.381.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161202151810.4fab9504@xeon-e3> <1480721075.18162.389.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36138 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcLEFi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 00:38:28 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so13469406wma.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 21:38:27 -0800 (PST)
In-Reply-To: <1480721075.18162.389.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 3, 2016 at 1:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-12-02 at 15:18 -0800, Stephen Hemminger wrote:
>>                                     name[i] = '@';
>> >
>> > ss.c: In function 'unix_show_sock':
>> > ss.c:3128:4: error: 'for' loop initial declarations are only allowed in C99 mode
>> > ss.c:3128:4: note: use option -std=c99 or -std=gnu99 to compile your code
>> > make[1]: *** [ss.o] Error 1
>> >
>> >
>> >
>>
>> Thanks, fixed by patch from Simon
>
> Right, thanks !


Thanks for notifying me. Sorry for the bug and thanks for the fix!
