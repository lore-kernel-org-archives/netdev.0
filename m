From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Fri, 16 Dec 2016 00:47:48 +0100
Message-ID: <CAHmME9pjoAHwTg_8hg9basCRvXq9JxfRduxmq8uMKCRi-YROtg@mail.gmail.com>
References: <CAHmME9p9cf1W3vhbu=YTRY1Xt=fmE1sVqY1XPt5iQwxfCfQUOA@mail.gmail.com>
 <e574d97f-e0b4-f5e2-6d60-88d3ce185249@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <e574d97f-e0b4-f5e2-6d60-88d3ce185249@stressinduktion.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 10:45 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> By the way, if you target net-next, it is currently closed. So no need
> to hurry.

Honestly I have no idea what I'm targeting. The hash function touches
lib/. The secure_seq stuff touches net/. The rng stuff touches
random.c. Shall this be for net-next? For lib-next (doesn't exist)?
For tytso-next? Since a lot of feedback has come from netdev people, I
suspect net-next is the correct answer. In that case, I'll ask Ted for
his sign-off to touch random.c, and then we'll get this queued up in
net-next. Please correct me if this doesn't actually resemble how
things work around here...

Jason
