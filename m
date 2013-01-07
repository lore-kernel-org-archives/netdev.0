From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/2] ipv6: fix packet corruption when Dest/RT2 options
 are used
Date: Mon, 7 Jan 2013 13:41:56 +0100
Message-ID: <20130107124156.GQ18940@secunet.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com>
 <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
 <50EAA84F.90408@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Romain KUNTZ <r.kuntz@ipflavors.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55116 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785Ab3AGMmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 07:42:07 -0500
Content-Disposition: inline
In-Reply-To: <50EAA84F.90408@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 11:49:51AM +0100, Nicolas Dichtel wrote:
> Le 05/01/2013 17:19, Romain KUNTZ a =E9crit :
> >Commit 299b0767 (ipv6: Fix IPsec slowpath fragmentation problem)
> Add Steffen into CC, he is the author of this patch and the IPsec
> maintainer.
>=20
> >has introduced a bug that provokes corrupted packets when Destinatio=
n
> >Options or Routing Header Type 2 are used (such as with Mobile IPv6)=
:
> >rt->rt6i_nfheader_len should be substracted to rt->dst.header_len,
> >and not to exthdrlen.

I had no Mobile IPv6 test case, so I likely overlooked this.

> >
> >This patch reverts to the original and correct behavior. Successfull=
y
> >tested with and without IPsec activated for MH packets.
> >
> >Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>

Thanks for catching!

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
