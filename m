From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: BUG: dst underflow (again)
Date: Sat, 6 Nov 2004 10:02:11 +0100
Message-ID: <20041106090211.GA8106@xi.wantstofly.org>
References: <4178AB0D.6060107@pobox.com> <20041022.155159.98771450.yoshfuji@linux-ipv6.org> <20041022075947.GA15795@xi.wantstofly.org> <1099577717.1039.155.camel@jzny.localdomain> <20041104221801.584c8f11.davem@davemloft.net> <20041105091427.GB28112@xi.wantstofly.org> <418B4B1A.8@conectiva.com.br> <20041105101513.GA28779@xi.wantstofly.org> <20041105162319.6e2917c5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, hadi@cyberus.ca, yoshfuji@linux-ipv6.org,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041105162319.6e2917c5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 05, 2004 at 04:23:19PM -0800, David S. Miller wrote:

> > > >IPSEC.. not that I know of.  So unless my distro does stuff behind
> > > >my back, no.  How do I make sure?
> > > 
> > > setkey -DP
> > 
> > Thanks.  Both machines I'm seeing this problem on have:
> > 
> > # setkey -DP
> > No SPD entries.
> > # 
> 
> Well, xfrm_lookup() is returning an error somehow, that's the only
> way to execute dst_release() in udpv6_sendmsg().  And xfrm_lookup()
> only returns errors if IPSEC policies have been configured either
> globally or locally for the socket.

Please note that my traces were made on the Fedora Core 2 kernel
('2.6.8-1.521smp'), where these codepaths all look a bit different.

I'm hoping to try a mainline kernel on one of these boxes soon.


cheers,
Lennert
