From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Wed, 16 Jul 2003 09:12:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307160905330.20100-100000@netcore.fi>
References: <200307152332.DAA09710@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <jmorris@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307152332.DAA09710@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > Such addresses are link-locals, of link local scope only.  A link-local 
> > IPv6 address is awfully difficult to remember and type for all of your 
> > possible links.
> > 
> > The only reasonable value user could supply is a global address.
> 
> So what? I do not see connection to previous. You want to live with global
> addresses as nexthop? 

Yes, I dare to say that they're a requirement. 

(But to be clear, when I talk about "global nexthop", I'm only interested 
in nexthops which are on-link.  That is, if you have prefix 
3FFF:FFFF:A:B::/64, setting 3FFE:FFFF:A:B::1 would be ok, but 
3FFE:FFFF:F00:BA::1 would not *have* to work.) 

> OK. But I remember you have spoken something quite
> opposite yesterday.

I don't recall that.  I think I was only suggesting that ONE possible way 
of implementing it (which I wouldn't think is the best one) is make that 
the user space tools' problem: i.e. make them resolve a globally addressed 
nexthop to a link-local nexthop.
 
> > Redundant information can be ignored.  This is not computer science
> > theory, removing everything which is not directly relevant.  The use of
> > the same representation for the next-hop (2002:F00:BA::x) as an address
> > (2002:BA:F00:y) is the only logical, user-friendly way.
> 
> What a bullshit... The second is address of host "x". The first is supposed
> to be address of host F00:BA, whatever it is. Probably, you can decrypt
> this only because poisoned by computer science. :-)

You read too much to in what I wrote (or maybe I wrote too much :-) -- 
what I mean is that 6to4 addresses have a very specific format.  It's 
completely illogical and unfriendly to the users to require use different 
formats when they use 6to4 addresses as nexthops and "normal" addresses.
 
> Just to complete discussion, let's stay on format fe80::A.B.C.D, for example.
> Unlike anothers it is 100% logically clean. :-)

I can't disagree with you there; it's simple, but it's NOT what 
specifications use and the *users* want and need to use.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
