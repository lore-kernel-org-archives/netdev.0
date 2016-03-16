From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
Date: Wed, 16 Mar 2016 10:18:33 -0700
Message-ID: <CA+55aFzhYJxCOXER-mhOfJ6=V13Rb5F0LB_3A9n7S_dLkb8f0g@mail.gmail.com>
References: <20160316115809.61b4478e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160316115809.61b4478e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 5:58 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Side note: can you change this wording for your manual merge script?
Last merge window (or was it the one before it?) we had confusion with
people who thought that "no action is required" means "you can just
ignore this entirely".

I want people who have known merge issues to at the very least
*mention* them to me when they send the pull request, and I also think
that trees that have merge conflicts that aren't just totally trivial
should also make sure that they have communicated with each other
about why the problem happened.

This is *particularly* true for the complete effing disaster that is
mellanox and rdma-vs-networking.

So please don't say "no action is required". Please make it clear that
there may not be any further action needed for linux-next itself, but
that other action may certainly be required.

Because I'm very close to not taking any rdma changes that touch
networking any more. Ever.

The Mellanox people are on my shit-list until they show that they can
actually act like responsible people and not just monkeys throwing
shit at the walls.

"No action required" is simply not true for Mellanox.

                     Linus
