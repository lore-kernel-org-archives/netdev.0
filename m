From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.5)
Date: Tue, 27 Nov 2007 03:00:53 +0900 (JST)
Message-ID: <20071127.030053.69931033.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37203 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbXKZSAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 13:00:45 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com> (at Mon, 26 Nov 2007 09:16:16 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This patch includes support for the Intra-Site Automatic Tunnel
> Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> module, and is configured using extensions to the "iproute2"
> utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
> distribution.
> 
> This version includes the diff for ./include/linux/if.h which was
> missing in the v2.4 submission and is needed to make the
> patch compile. The patch has been installed, compiled and
> tested in a clean 2.6.24-rc2 kernel build area.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Note:
With linux-2.6:
| % patch -p1 < /tmp/isatap.patch 
| patching file include/linux/if.h
| patching file include/linux/if_tunnel.h
| patching file include/linux/in.h
| patching file include/net/addrconf.h
| patching file net/ipv6/addrconf.c
| patching file net/ipv6/route.c
| Hunk #1 succeeded at 1660 (offset -8 lines).
| patching file net/ipv6/sit.c

With net-2.6.24:
| % patch -p1 < /tmp/isatap.patch
| % patch -p1 < /tmp/isatap.patch 
| patching file include/linux/if.h
| patching file include/linux/if_tunnel.h
| patching file include/linux/in.h
| patching file include/net/addrconf.h
| patching file net/ipv6/addrconf.c
| Hunk #1 succeeded at 378 (offset -1 lines).
| Hunk #2 succeeded at 1441 (offset -1 lines).
| Hunk #3 succeeded at 1479 (offset -1 lines).
| Hunk #4 succeeded at 2210 (offset -1 lines).
| patching file net/ipv6/route.c
| Hunk #1 succeeded at 1727 (offset 59 lines).
| patching file net/ipv6/sit.c

--yoshfuji
