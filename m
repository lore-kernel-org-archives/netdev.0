From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 18:38:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063388303.7869.410.camel@imladris.demon.co.uk>
References: <Pine.LNX.4.44.0309122023050.27849-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309122023050.27849-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 20:29 +0300, Pekka Savola wrote:
> You have this wrong assumption that IPv6 is engineered with RFC1918 in 
> mind.  Site-locals were indeed that.  But the point of deprecating them 
> was to get *rid of* (at least to a degree) RFC1918 addresses in IPv6.

But RFC1918 is what makes intranets work. And the proposal you pointed
me at puts them _back_ again, just gratuitously globally unique, and
without the semantics which actually made them _more_ useful than
RFC1918; made them ideal for multi-homing with both site- and global-
scope addresses.

> It's no use to reply in detail, except to correct two very bad 
> misunderstandings..

> Leakage is used to refer to a lot more than just source/destination 
> addresses.  For example, addresses leak when you use a Peer-to-peer system 
> behind a NAT; addresses leak when you contact to an FTP server from behind 
> a NAT, etc.  Addresses leaking inside the application is a much more 
> difficult problem.

Unlike IPv4 and RFC1918, I thought IPv6 and site-local addressing
_solved_ this, by letting multi-homing work properly. Hosts _wouldn't_
contact external machines using their site-scope address through a NAT;
instead they'd have a global-scope address for that. Wasn't that the
point?

> Consider the case when you have a router which is part of *two* sites,
> each from overlapping addresses.  Routing protocols and everything would 
> have to be modified to pass site identifiers in addition to the addresses.  
> This looks like a simple problem but it isn't, that's for sure.

OK, I hadn't realised you could have overlapping sites, and you were
supposed to magically distinguish between them without any site
identifier being passed on the wire. That was rather bizarre, and
there's definitely reason for _that_ being abolished, I suppose. 

The site scope addresses gave you 118 bits to play with. Using multiple
'site identifiers' rather than just subnetting it is a strange idea. 

-- 
dwmw2
