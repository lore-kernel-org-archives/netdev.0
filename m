From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 01 Sep 2003 11:24:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901.112409.61391981.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0309010249070.26242-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0309010257390.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0309010257390.26242-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0309010257390.26242-200000@rhea.tcs.hut.fi> (at Mon, 1 Sep 2003 03:11:58 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> unless (link-local) protocols like DHCPv6 or MLD are run over the virtual
> link formed by IPv6 tunnels, the net_devices representing the tunnels
> don't necessarily need to have an IPv6 address configured specifically to
> them.

Wrong. All interfaces have a link-local address. (RFC2462)

--yoshfuji
