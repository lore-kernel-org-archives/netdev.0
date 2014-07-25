From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 20:38:17 +0200
Message-ID: <1406313497.3363.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
	 <53D27E0E.40102@cs.unm.edu>
	 <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFwZrF88Fj7arP2P3rRshBTaxbjyJkKuOAu2Y4tVQ3kWWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeffrey Knockel <jeffk@cs.unm.edu>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:50264 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261AbaGYSi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:38:29 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so4605844wgh.25
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 11:38:25 -0700 (PDT)
In-Reply-To: <CA+55aFwZrF88Fj7arP2P3rRshBTaxbjyJkKuOAu2Y4tVQ3kWWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-25 at 11:35 -0700, Linus Torvalds wrote:
> On Fri, Jul 25, 2014 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > We might change the hash to use both daddr & saddr to increase
> > protection.
> 
> .. and maybe protocol too, so that you can't easily use icmp echo
> packets to do it for udp packets etc. The underlying jhash is
> jhash_3words(), so that would actually be fairly natural for at least
> ipv4 (the ipv6 case I didn't look at).

Right, in fact saddr is probably not worth it.

Its not like servers have dozen of IPv4 addresses anyway...
