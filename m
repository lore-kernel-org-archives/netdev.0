From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Wed, 28 Jan 2004 08:39:38 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401280836530.14588-100000@netcore.fi>
References: <20040128.084601.13486645.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040128.084601.13486645.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> On performance issue: as IPv4, we may want to have 
> net.ipv6.conf.<if>.proxy_ndisc sysctl.

IPv4 proxy_arp is different.  It's the way of configuring automatic
proxy ARP.  No such thing exists for IPv6 at the moment, so when we
implement ND proxying, it would probably be the place to toggle it on
and off.  So I see little need for a sysctl toggle to switch this on
and off, as the addresses to be proxied are currently manually
configured anyway.

> We may also want to have another configuration 
> option (to enable proxy) bacause not all routers require this 
> feature.

I'm not sure whether this is called for, for a small piece of code
like this.  We need fewer configuration options, not more! :-)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
