From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
Date: Fri, 16 Nov 2007 03:44:16 +0900 (JST)
Message-ID: <20071116.034416.19410547.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
	<20071115.204810.131957203.yoshfuji@linux-ipv6.org>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC31@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33556 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760386AbXKOSoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:44:18 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC31@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDC31@XCH-NW-7V2.nw.nos.boeing.com> (at Thu, 15 Nov 2007 10:11:16 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> Yoshifuji, 
> 
> > -----Original Message-----
> > From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> > Sent: Thursday, November 15, 2007 3:48 AM
> > To: Templin, Fred L
> > Cc: netdev@vger.kernel.org; vladislav.yasevich@hp.com; 
> > yoshfuji@linux-ipv6.org
> > Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
> > 
> > In article 
> > <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.bo
> > eing.com> (at Wed, 14 Nov 2007 22:44:17 -0800), "Templin, 
> > Fred L" <Fred.L.Templin@boeing.com> says:
> > 
> > > From: Fred L. Templin <fred.l.templin@boeing.com>
> > > 
> > > This patch includes support for the Intra-Site Automatic Tunnel
> > > Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> > > module, and is configured using extensions to the "iproute2"
> > > utility.
> > > 
> > > The following diffs are specific to the Linux 2.6.24-rc2 kernel
> > > distribution. This message includes the full and patchable 
> > diff text;
> > > please use this version to apply patches.
> > > 
> > > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > BTW, how will we handle DNS name (and TTL) and/or multiple PRL entries 
> > in RFC4214?
> > 
> > I'm doubting if we really need to handle PRL refresh in kernel.
> 
> DNS name and PRL refresh are done in a daemon that either exec's
> 'ip' or issues the device ioctl's directly. When there are multiple default
> router IPv4 addresses, the daemon picks one as the primary and writes
> it to the kernel. It can then change to a different primary later if it wants
> to. Also possible is something like VRRP to allow several routers for
> fault tolerance even though there is only a single default router address. 

Why?  All PRLs should be installed in kernel so that standard router 
selection can be used.  For this, I think we should have just one
isatap interface per set of PRLs provideing virtual link,
especially if each of them provides the same prefix.

--yoshfuji
