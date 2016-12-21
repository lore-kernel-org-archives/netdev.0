From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [kernel-hardening] Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 09:08:21 -0800
Message-ID: <1482340101.8944.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161221032829.3031.qmail@ns.sciencehorizons.net>
         <1482298164.8944.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAHmME9oCfCwAq1qP09uAN6vvakh4wXDMHunsL9D7W_LDeN_OQQ@mail.gmail.com>
         <1482335804.8944.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1482338385.11006.67.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-hardening@lists.openwall.com,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: Rik van Riel <riel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33801 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932859AbcLURIj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 12:08:39 -0500
In-Reply-To: <1482338385.11006.67.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 11:39 -0500, Rik van Riel wrote:

> Does anybody still have a P4?
> 
> If they do, they're probably better off replacing
> it with an Atom. The reduced power bills will pay
> for replacing that P4 within a year or two.

Well, maybe they have millions of units to replace.

> 
> In short, I am not sure how important the P4
> performance numbers are, especially if we can
> improve security for everybody else...

Worth adding that the ISN or syncookie generation are less than 10% of
the actual cost of handling a problematic (having to generate ISN or
syncookie) TCP packet anyway.

So we are talking of minors potential impact for '2000-era' cpus.

Definitely I vote for using SipHash in TCP ASAP.
