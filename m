From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/01] ipv6: RFC4214 Support (v2.5)
Date: Tue, 27 Nov 2007 08:57:58 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC54@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com> <20071127.030053.69931033.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vladislav.yasevich@hp.com>,
	<davem@davemloft.net>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:58241 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757047AbXK0RAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 12:00:04 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071127.030053.69931033.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> Sent: Monday, November 26, 2007 10:01 AM
> To: herbert@gondor.apana.org.au
> Cc: Templin, Fred L; netdev@vger.kernel.org; 
> vladislav.yasevich@hp.com; davem@davemloft.net; 
> yoshfuji@linux-ipv6.org
> Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.5)
> 
> In article 
> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.bo
> eing.com> (at Mon, 26 Nov 2007 09:16:16 -0800), "Templin, 
> Fred L" <Fred.L.Templin@boeing.com> says:
> 
> > From: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > This patch includes support for the Intra-Site Automatic Tunnel
> > Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> > module, and is configured using extensions to the "iproute2"
> > utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
> > distribution.
> > 
> > This version includes the diff for ./include/linux/if.h which was
> > missing in the v2.4 submission and is needed to make the
> > patch compile. The patch has been installed, compiled and
> > tested in a clean 2.6.24-rc2 kernel build area.
> > 
> > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Note:
> With linux-2.6:
> | % patch -p1 < /tmp/isatap.patch 
> | patching file include/linux/if.h
> | patching file include/linux/if_tunnel.h
> | patching file include/linux/in.h
> | patching file include/net/addrconf.h
> | patching file net/ipv6/addrconf.c
> | patching file net/ipv6/route.c
> | Hunk #1 succeeded at 1660 (offset -8 lines).
> | patching file net/ipv6/sit.c

Confirmed in a clean linux-2.6.24-rc3 build area:

  - Installed patch with identical results as above.
  - Verified that the patch installed correctly (it did).
  - Compiled, booted and tested.

Fred
fred.l.templin@boeing.com 

> With net-2.6.24:
> | % patch -p1 < /tmp/isatap.patch
> | % patch -p1 < /tmp/isatap.patch 
> | patching file include/linux/if.h
> | patching file include/linux/if_tunnel.h
> | patching file include/linux/in.h
> | patching file include/net/addrconf.h
> | patching file net/ipv6/addrconf.c
> | Hunk #1 succeeded at 378 (offset -1 lines).
> | Hunk #2 succeeded at 1441 (offset -1 lines).
> | Hunk #3 succeeded at 1479 (offset -1 lines).
> | Hunk #4 succeeded at 2210 (offset -1 lines).
> | patching file net/ipv6/route.c
> | Hunk #1 succeeded at 1727 (offset 59 lines).
> | patching file net/ipv6/sit.c
> 
> --yoshfuji
> 
