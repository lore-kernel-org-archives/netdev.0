From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Thu, 24 Jul 2014 11:21:09 -0700
Message-ID: <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:49916 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933391AbaGXSVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 14:21:10 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so5602010vcb.30
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 11:21:09 -0700 (PDT)
In-Reply-To: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 1:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This patch adds a random amount of perturbation so that IP identifiers
> for a given destination [1] are no longer monotonically increasing after
> an idle period.

This certainly looks good to me. It would be good to have actual
testing by Jeffrey &al, but this seems simple and complete.

            Linus
