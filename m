From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Tue, 15 Jul 2003 20:29:11 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307152025570.14070-100000@netcore.fi>
References: <200307151446.SAA08540@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307151446.SAA08540@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > "resolve" next-hops.  I.e., the requirement that the users/protocols will
> > give you non-final nexthop information which you have to "resolve" to get
> > the final nexthop (e.g. a global address -> a link-local address 
> > obtained using Neighbor Discovery).
> 
> No way to resolve exists, unless it already embedded to corresponding
> protocol.

Assume you're a host on a link with prefix 3FFE:FFFF:A:B::/64.  The router 
is the one with interface ID one.

What happens when you do "ping6 3FFE:FFFF:A:B::1" ? Seems to resolve a 
link-local address for the router just fine.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
