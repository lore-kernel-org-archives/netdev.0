From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Tue, 16 Oct 2012 18:55:22 +0200
Message-ID: <1350406522.3954.1242.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
	 <1350285275.22442.17.camel@joe-AO722>
	 <1350286790.21172.17414.camel@edumazet-glaptop>
	 <1350300302.22442.25.camel@joe-AO722>
	 <1350304308.3954.66.camel@edumazet-glaptop>
	 <CAO_aot59XNERsb7q9pZSpSzyFLv=pKEk6wb82PE-sNMf4TDXow@mail.gmail.com>
	 <1350307293.3954.119.camel@edumazet-glaptop>
	 <CAO_aot44shT8CKtCi8Zv0GWN7wjybHX+d5SFQ1daVOh84v+L1g@mail.gmail.com>
	 <CAO_aot66K-7Je8dSnYTxxkoaDgQ3JpG7t=MdTK0A0ixPX_AP-A@mail.gmail.com>
	 <1350405787.3954.1229.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60628 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab2JPQze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 12:55:34 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3134968bkc.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 09:55:32 -0700 (PDT)
In-Reply-To: <1350405787.3954.1229.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 18:43 +0200, Eric Dumazet wrote:
> On Tue, 2012-10-16 at 18:07 +0200, Jan Hinnerk Stosch wrote:
> > 2012/10/15 Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>:
> > >
> > > Yes. Attached..
> > 
> > Today I read about the existence of the "git bisect" function and if I
> > have not done anything wrong the "bad commit" which lead to this
> > regression is ddbe503203855939946430e39bae58de11b70b69.
> > Perhaps this can help you.
> 
> Interesting, I was about to ask you to do a bisection ;)
> 
> So the hash value of ::1 was changed, and it has bad effect on your
> machine...
> 
> Could it be hash collision and an old bug being uncovered ?
> 
> Could you trace inet6_addr_hash() a bit ?

Dont bother, I found the bug. Its related to network namespaces

I'll send a fix asap.

Thanks !
