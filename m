From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Wed, 28 Jan 2004 08:46:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128.084601.13486645.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
	<20040116.005443.92504522.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.58.0401272244360.28384@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0401272244360.28384@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0401272244360.28384@rhea.tcs.hut.fi> (at Tue, 27 Jan 2004 22:58:02 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> How about this fix? I think it's cleaner than the one I proposed
> earlier. The down side with it is that all nodes, no matter if they are
:

Well, it seems better to me.

I however think it should be done in ip6_forward()
because "proxying" is done at the router, acting as proxy.
Packets sent to the proxying router are basically forwarded 
to the original node even if the destination is link-local.

On performance issue: as IPv4, we may want to have 
net.ipv6.conf.<if>.proxy_ndisc sysctl.
We may also want to have another configuration 
option (to enable proxy) bacause not all routers require this 
feature.

BTW, would you please give me a few days, till my defence over? :-)

--yoshfuji
