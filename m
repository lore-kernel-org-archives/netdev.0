From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and
 code
Date: Tue, 10 Aug 2004 10:32:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040810.103229.128092044.yoshfuji@linux-ipv6.org>
References: <20040809175404.301bd60a@localhost>
	<20040809170705.6ab75c5f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040809170705.6ab75c5f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040809170705.6ab75c5f.davem@redhat.com> (at Mon, 9 Aug 2004 17:07:05 -0700), "David S. Miller" <davem@redhat.com> says:

> Truly %100 RAW sockets should have their packets untouched by
> the kernel.  User wants exactly that packet to be sent onto
> the wire.

Does it make sense to excude IPPPROTO_RAW sockets and/or hdrincl sockets, 
which would be 100% truly raw socket?
Or, do we add some socket option for this?

Mip6 is required to exchange ipsec'ed datagrams (!= IPPROTO_RAW).
(as I told you at Networking Summit if I remember correctly),
so we need some sort of the patch, anyway.

Thanks.

--yoshfuji
