From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4
 tunneling)
Date: Sun, 16 Jan 2005 21:51:41 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0501162140460.10874@netcore.fi>
References: <20050112222437.GC14280@xi.wantstofly.org>
 <Pine.LNX.4.61.0501130944270.19573@netcore.fi> <20050113092351.GA23170@xi.wantstofly.org>
 <1105897020.1091.736.camel@jzny.localdomain> <20050116185553.GA21739@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050116185553.GA21739@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 16 Jan 2005, Lennert Buytenhek wrote:
> If we do end up using GRE for ethernet tunneling, there's some work that
> needs to be done.  For one, ip_gre in its current form would need a certain
> amount of hacking for tunneling ethernet frames instead of IPv4/IPv6 as
> it does now.  We might as rename it to plain 'gre' and move it out of
> net/ipv4/ to net/core/ or something while we're at it.

Now that I think about this a bit more, there may be a potential 
issue..

If the payload of GRE is an ethernet frame, which GRE 'Protocol Type' 
(i.e., ethertype) would that be?

I doubt anyone has defined an ethertype which would be used to 
transmit full ethernet frames inside an ethernet header, so this would 
likely need to be some special value..

http://www.iana.org/assignments/ethernet-numbers

(Another solution for this problem space is obviously L2TP, which is 
also rather widely supported..)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
