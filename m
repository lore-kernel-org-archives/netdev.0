From: Neal Cardwell <ncardwell@google.com>
Subject: Re: net/ipv4: divide error in __tcp_select_window
Date: Thu, 31 Aug 2017 15:37:13 -0400
Message-ID: <CADVnQy=GA_neQ2CsXmdZbPozcd-N6iUoX-jXZkNgXocPVo2efg@mail.gmail.com>
References: <CADUsjNnba_AmnTdoY45Bh7HasqjmBja-W1+-+6eMt-d_dCs2qA@mail.gmail.com>
 <CADVnQynuyK5H1SDOnzDZPOnVn701JhrSQRCORVJ_6c=z_EooBw@mail.gmail.com> <20170831.122543.754410467437404852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: idaifish <idaifish@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Netdev <netdev@vger.kernel.org>, syzkaller@googlegroups.com,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:36342 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdHaTho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 15:37:44 -0400
Received: by mail-qt0-f181.google.com with SMTP id v20so2821676qtg.3
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 12:37:44 -0700 (PDT)
In-Reply-To: <20170831.122543.754410467437404852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 3:25 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Neal Cardwell <ncardwell@google.com>
> Date: Thu, 31 Aug 2017 07:11:28 -0400
>
> > Thanks for the report. I believe this tcp_recvmsg  => tcp_cleanup_rbuf
> >  => __tcp_select_window divide-by-zero issue was fixed in May by Wei,
> > in:
> >
> >  499350a5a6e7 tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0
> >  https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=499350a5a6e7
> >
> > Looks like we should probably mark this as a -stable candidate, so
> > that it will eventually make it to 4.4.y, 4.9.y, 4.12.y users, etc. (I
> > don't see the commit in those stable branches.)
>
> Ok, queued up for -stable, thanks.

Great. Thanks!

neal
