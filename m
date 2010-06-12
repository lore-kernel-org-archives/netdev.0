From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] tcp: unify tcp flag macros
Date: Sat, 12 Jun 2010 23:33:57 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006122327420.4502@obet.zrqbmnf.qr>
References: <1276322372-12584-1-git-send-email-xiaosuo@gmail.com> <alpine.LSU.2.01.1006121017380.28286@obet.zrqbmnf.qr> <AANLkTikZSn5zJYNPU2mdcBiyY7jfBOvq0f1khlbue4JD@mail.gmail.com> <20100612.141715.220059291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: xiaosuo@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:47717 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491Ab0FLVd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jun 2010 17:33:58 -0400
In-Reply-To: <20100612.141715.220059291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 2010-06-12 23:17, David Miller wrote:
>
>> The same macros are definied by BSDs too. So I think it is better to
>> keep them the same.
>
>That is an absolutely meaningless argument.
>
>This is a "net/*.h" header, not something in "linux/*.h"
>that application in userspace might want access to.
>
>It's entirely private to the kernel, therefore we do what
>makes the most sense (from a cleanliness and namespace
>perspective) rather than "what other people do."

And we'd also need to fight netinet/in.h in userspace programs,
because they do already define TH_*.

