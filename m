From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.5)
Date: Thu, 29 Nov 2007 21:29:40 +1100
Message-ID: <20071129102940.GC22537@gondor.apana.org.au>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com> <4739D7F7.90300@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1828 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762257AbXK2K35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:29:57 -0500
Content-Disposition: inline
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 05:16:16PM +0000, Templin, Fred L wrote:
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

Sorry, the patch doesn't apply to net-2.6.25.

$ git apply --check --whitespace=error-all ~/p
Space in indent is followed by a tab.
/home/gondolin/herbert/p:101:                          "%s: Disabled Multicast RS\n",
Space in indent is followed by a tab.
/home/gondolin/herbert/p:216:           }
Space in indent is followed by a tab.
/home/gondolin/herbert/p:252:                           printk(KERN_DEBUG "sit: nexthop == NULL\n");
Space in indent is followed by a tab.
/home/gondolin/herbert/p:254:           }
fatal: corrupt patch at line 269
$

There seems to be a line missing at the end.  Please fix the white space
errors and resend.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
