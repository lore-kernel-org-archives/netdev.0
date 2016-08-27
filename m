From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] rhashtable: fix a memory leak in alloc_bucket_locks()
Date: Fri, 26 Aug 2016 18:25:06 -0700
Message-ID: <CA+55aFwaAA--uDeD5crQzU6kn+2QF4xJN1i0LyTU8xg3zT_n9w@mail.gmail.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
 <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
 <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
 <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com> <1300419617.2731697.1472233247078.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>
To: CAI Qian <caiqian@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33973 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752303AbcH0BZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 21:25:08 -0400
Received: by mail-oi0-f66.google.com with SMTP id t127so8165088oie.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 18:25:08 -0700 (PDT)
In-Reply-To: <1300419617.2731697.1472233247078.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 10:40 AM, CAI Qian <caiqian@redhat.com> wrote:
> After applied to this patch and ran the reproducer (compiling gcc), had
> no bucket_table_alloc in kmemleak report anymore. Hence,
>
> Tested-by: CAI Qian <caiqian@redhat.com>
>
> Funny enough, it now gave me this,
>
> [ 3406.807461] kmemleak: 1353 new suspected memory leaks (see /sys/kernel/debug/kmemleak)

Those logs look incomprehensible. This one looks more like a kmemleak
bug than anything else.

            Linus
