From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 12:48:06 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309121234261.23575-100000@netcore.fi>
References: <1063354018.23778.376.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063354018.23778.376.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003, David Woodhouse wrote:
> I don't really want to make every internal box do mobile-ipv6 for
> _itself_, but I think it can be done by the local router on their
> behalf.

I wouldn't spend too many cycles on this; the issue is far from trivial, 
trust me :-)
 
[...]
> All the alternatives, apart from the first 'use site-local addresses for
> internal operation, global-scope addresses for external', are looking
> fairly complex and fragile, to be honest.
> 
> Part of me wants to say 'Sod it', and assume that site-local scope isn't
> going to actually be abolished, since doing so seems to be _such_ a bad
> idea once you try to work around its absence.

Well, I can say for certain that site-locals are going out.  However,
nothing prevents still using them, though.  However, it's likely that
you'd have to redesign the network, or at least renumber it if you choose
that path.

A year or two down the path, there may be another "local addressing" 
approach.. there is already a proposal:

http://www.ietf.org/internet-drafts/draft-ietf-ipv6-unique-local-addr-00.txt

.. but whether thats *the* way, or a way at all, remains to be seen.

You might also want to check out the document which is documenting the 
deprecation (note, it's still a draft version, and likely to evolve a 
lot), to learn about some of the problems of the site-locals:

http://www.ietf.org/internet-drafts/draft-ietf-ipv6-deprecate-site-local-00.txt

One possible, conceptually maybe easier way, would be to deploy a single,
internal ISATAP domain (so you'd have only _one_ internal IPv6 subnet,
which would really be just automatic tunnel between all v6 hosts in your
enterprise), but that would require getting ISATAP in all the kernels and
iputils you use first, and IMHO it wouldn't be the same as deployingi real 
IPv6... :-)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
