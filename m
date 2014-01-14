From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net-next 2/5] {IPv4,xfrm} Add ESN support for AH
 ingress part
Date: Tue, 14 Jan 2014 11:51:02 +0100
Message-ID: <20140114105102.GK31491@secunet.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
 <1389663552-29638-3-git-send-email-fan.du@windriver.com>
 <20140114095425.GH31491@secunet.com>
 <52D50AFC.6030302@windriver.com>
 <20140114100900.GI31491@secunet.com>
 <52D50EB6.3010301@windriver.com>
 <20140114103426.GJ31491@secunet.com>
 <52D5144B.605@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36982 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbaANKvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 05:51:04 -0500
Content-Disposition: inline
In-Reply-To: <52D5144B.605@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 06:41:15PM +0800, Fan Du wrote:
>=20
>=20
> On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 18:34, Steffen Klassert wrote:
> >On Tue, Jan 14, 2014 at 06:17:26PM +0800, Fan Du wrote:
> >>On 2014=E5=B9=B401=E6=9C=8814=E6=97=A5 18:09, Steffen Klassert wrot=
e:
> >
> >No, I mean something like:
> >
> >sg_init_table(sg, nfrags + sglists)
> >
> >if (x->props.flags&  XFRM_STATE_ESN) {
> >	*seqhi =3D XFRM_SKB_CB(skb)->seq.input.hi;
> >	sg_set_buf(sg + nfrags, seqhi, seqhi_len);
> >}
> >
>=20
> hehe, it's the same as the option this patch used.

No, you don't need to sg_unmark_end() before you can add
your entry and it is more obvious what happens here.

Also, I'm not absolutely sure whether the sg magic allows
what you did. Did you test with sg debugging enabled?

> Anyway, I will make it as you suggested in the next round review.
>=20

Thanks!
