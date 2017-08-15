From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: general protection fault in fib_dump_info
Date: Tue, 15 Aug 2017 02:49:20 -0700
Message-ID: <1502790560.4936.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
         <1502767994.4936.47.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADUsjNmyusiq+fCChitacZwzHYJVO3_8a60A5=G=Ga2x4Y6xqw@mail.gmail.com>
         <CACT4Y+bnZxac87Bz6VYLhAzpn5JG-bmm7kzPefoYzDP7z9rftw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: idaifish <idaifish@gmail.com>, David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36136 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdHOJtW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 05:49:22 -0400
Received: by mail-pg0-f42.google.com with SMTP id i12so3079470pgr.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 02:49:22 -0700 (PDT)
In-Reply-To: <CACT4Y+bnZxac87Bz6VYLhAzpn5JG-bmm7kzPefoYzDP7z9rftw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 08:51 +0200, Dmitry Vyukov wrote:
> Eric, what's the "David Miller net tree"? Is it
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git? I
> don't see 2c87d63ac853550e734edfd45e1be5e5aa44fbcc there.
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git is
> what we are testing and the last commit on which we saw this bug is:
> 
> commit cb44a8606f063099991242ada4b8fa2fb26769b3
> Merge: 54161ed4eede a656d34a6e5a
> Author: David S. Miller
> Date:   Mon Aug 14 11:18:16 2017 -0700
>     Merge branch 'mlnx-i2c'
> 

Extracted from Documentation/networking/netdev-FAQ.txt

A: There are always two trees (git repositories) in play.  Both are driven
   by David Miller, the main network maintainer.  There is the "net" tree,
   and the "net-next" tree.  As you can probably guess from the names, the
   net tree is for fixes to existing code already in the mainline tree from
   Linus, and net-next is where the new code goes for the future release.
   You can find the trees here:

        https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
        https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git


Hope this helps.
