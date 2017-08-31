From: David Miller <davem@davemloft.net>
Subject: Re: net/ipv4: divide error in __tcp_select_window
Date: Thu, 31 Aug 2017 12:25:43 -0700 (PDT)
Message-ID: <20170831.122543.754410467437404852.davem@davemloft.net>
References: <CADUsjNnba_AmnTdoY45Bh7HasqjmBja-W1+-+6eMt-d_dCs2qA@mail.gmail.com>
        <CADVnQynuyK5H1SDOnzDZPOnVn701JhrSQRCORVJ_6c=z_EooBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idaifish@gmail.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
        syzkaller@googlegroups.com, weiwan@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdHaTZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 15:25:46 -0400
In-Reply-To: <CADVnQynuyK5H1SDOnzDZPOnVn701JhrSQRCORVJ_6c=z_EooBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 31 Aug 2017 07:11:28 -0400

> Thanks for the report. I believe this tcp_recvmsg  => tcp_cleanup_rbuf
>  => __tcp_select_window divide-by-zero issue was fixed in May by Wei,
> in:
> 
>  499350a5a6e7 tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0
>  https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=499350a5a6e7
> 
> Looks like we should probably mark this as a -stable candidate, so
> that it will eventually make it to 4.4.y, 4.9.y, 4.12.y users, etc. (I
> don't see the commit in those stable branches.)

Ok, queued up for -stable, thanks.
