From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Undocumented IPv6 options
Date: Mon, 15 Oct 2007 10:39:03 +0300
Message-ID: <20071015073903.GR6372@mea-ext.zmailer.org>
References: <47130EB9.3090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, linux-man@vger.kernel.org,
	Andrew McDonald <andrew@mcdonald.org.uk>,
	linux-net@vger.kernel.org
To: Michael Kerrisk <mtk.manpages@googlemail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47130EB9.3090405@gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 08:54:49AM +0200, Michael Kerrisk wrote:
> Hello netdev,
> 
> Andrew McDonald kindly fixed the description of IPV6_ROUTER_ALERT in the
> ipv7.7 man page.  As long as we're on the topic, I'll point out that the
> following IPV6 options (and possibly others) are still not documented on
> that page:
> 
> IPV6_CHECKSUM
> IPV6_JOIN_ANYCAST
> IPV6_LEAVE_ANYCAST
> IPV6_V6ONLY
> IPV6_RECVPKTINFO
> IPV6_2292PKTINFO
> 
> Can anyone help with documenting any of these please?

RFC 2553 was obsoleted by RFC 3493, and it added IPV6_V6ONLY into Basic API.

RFC 2292 (IPV6 Advanced API) defines IPV6_CHECKSUM, and IPV6_PKTINFO
(latter of which is known above as IPV6_2292PKTINFO)

RFC 3542 obsoletes RFC 2292, and defines IPV6_RECVPKTINFO, and
modifies IPV6_PKTINFO.

The  IPV6_JOIN_ANYCAST  and  IPV6_LEAVE_ANYCAST  are not defined in any RFC.

Undocumented are also IPV6_JOIN_GROUP and IPV6_LEAVE_GROUP (RFC 2553 / 3493)


It really looks like time for major overhaul of that (and related) man-pages
is needed...

> Cheers,
> 
> Michael
> -- 
> Michael Kerrisk
> maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

/Matti Aarnio
