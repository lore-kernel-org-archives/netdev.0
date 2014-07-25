From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 11:35:39 -0700
Message-ID: <CA+55aFwZrF88Fj7arP2P3rRshBTaxbjyJkKuOAu2Y4tVQ3kWWA@mail.gmail.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
	<53D27E0E.40102@cs.unm.edu>
	<1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeffrey Knockel <jeffk@cs.unm.edu>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:58408 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbaGYSfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:35:40 -0400
Received: by mail-vc0-f182.google.com with SMTP id hy4so7882206vcb.41
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 11:35:40 -0700 (PDT)
In-Reply-To: <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> We might change the hash to use both daddr & saddr to increase
> protection.

.. and maybe protocol too, so that you can't easily use icmp echo
packets to do it for udp packets etc. The underlying jhash is
jhash_3words(), so that would actually be fairly natural for at least
ipv4 (the ipv6 case I didn't look at).

               Linus
