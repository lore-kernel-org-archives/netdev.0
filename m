From: "John S. Denker" <jsd@monmouth.com>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 22:33:57 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EDC0915.1080109@monmouth.com>
References: <32804.4.64.196.31.1054351332.squirrel@www.osdl.org>	<20030530.234211.102567405.davem@redhat.com>	<20030602140452.039248de.rddunlap@osdl.org> <20030602.145619.71112623.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	David Brownell <david-b@pacbell.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030602.145619.71112623.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On 06/02/2003 05:56 PM, David S. Miller wrote:
 >>
 >> I always have to wonder about someone who can't live with just
 >> working code to study, and absolutely requires some document
 >> describing it.
 >>
 >> What is better or more accurate description than code itself!?!?!

I am very grateful for the kindness of those who
have written the code in question and made it
available to help others.  I wish to repay that
with help and kindness, not the opposite.  Today
I can help by speaking the truth, and the truth
is that documentation is sorely needed.

There's no point in writing code if few people
use it.  Linux is hanging in there at a few
percent market share.  That's not going to grow
unless there is better documentation.


On 06/02/2003 09:56 PM, David Brownell replied:
 >
 > Well, the difference between code and its spec is
 > generally a bug that needs to be fixed ... which
 > can be in the code as well as in the spec.  And for
 > reasonable design specs, it's more likely in the code.
 >
 > But if there's only the code, it gets a lot more
 > troublesome when things don't behave "as expected".
 >
 > People who are in a position to change the code
 > to meet their expectations may not care, but that's
 > rarely a significant chunk of the user community.
 >
 > And in particular, writing tests against the code
 > is generally the wrong way to go.  They need to be
 > written against some kind of spec.

I have to agree with Mr. Brownell on this one.


 >> What is better or more accurate description than code itself!?!?!

There are two ideas mixed up there.
  -- Better documentation.
  -- Accurate description.

1) Yes, code is the most accurate description of the code.
But it is not to be confused with good documentation.

2) Documentation should be clear and concise.
Code must attend to all the details.

3) Sometimes efficiency requires that the code be
tricky.  Documentation must not be tricky.

4) In theory, very well-commented code might
approximate its own documentation.  But I haven't
seen any such code lately.  Here are _all_ the
comments from xfrm_input.c, a 454-line file:

/* Fetch spi and seq frpm ipsec header */
         /* Allocate new secpath or COW existing one. */
/* Fetch spi and seq frpm ipsec header */
                 iph = skb->nh.ipv6h; /* ??? */
                 if (x->props.mode) { /* XXX */
         /* Allocate new secpath or COW existing one. */
#endif /* CONFIG_IPV6 || CONFIG_IPV6_MODULE */


If you were teaching a programming course, how would
you grade an assignment turned in with that level of
commenting?

5) In the engine of a piston-driven airplane, there
are two spark plugs in every cylinder.  Obviously
that costs twice as much and weighs twice as much
as having only one.  But the redundancy makes the
system thousands of times more reliable.

Similarly, writing code _and_ documetation is about
twice as expensive as writing the code alone.  But
the redundancy makes it possible to achieve much
greater reliability.  Also maintainability and
extensibility.

6) Adding extra vehemence '!?!?!' does not add
clarity to the discussion.

*) et cetera.


