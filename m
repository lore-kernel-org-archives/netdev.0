From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling broken
Date: Fri, 11 Jul 2003 11:03:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.110358.32018240.yoshfuji@linux-ipv6.org>
References: <20030710233931.GG1722@zip.com.au>
	<1057881869.3588.10.camel@hades>
	<1057888154.26854.324.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mika.liljeberg@welho.com, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andre@tomt.net
In-Reply-To: <1057888154.26854.324.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1057888154.26854.324.camel@localhost> (at 11 Jul 2003 03:49:14 +0200), Andre Tomt <andre@tomt.net> says:

> Thanks for the explanation, I've been struggling to understand what
> Yoshfuji tried to explain to me earlier on this topic (see "IPv6 bugs
> introduced in 2.4.21" - ie. my bogus bugreport), now it all makes
> perfect sense :-)

Sorry for my poor explanation...


> If you don't have anything but one /64 for example.. I guess /126's
> would be ok as you could rule out the the anycast address? It will
> probably work with Linux - but is it wrong in any sense, other than
> "breaking" with EUI-64/autoconfiguration?

I don't think so, but I won't recoomend doing this.
(I even don't assign global addresses to p-t-p interface at all.)

--yoshfuji
