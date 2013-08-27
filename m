From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for
 xfrm tunnel mode callback
Date: Tue, 27 Aug 2013 11:28:56 +0200
Message-ID: <20130827092856.GC7660@secunet.com>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
 <20130826.162135.1765443562851401512.davem@davemloft.net>
 <521C0104.2070906@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, saurabh.mohan@vyatta.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48893 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623Ab3H0J26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 05:28:58 -0400
Content-Disposition: inline
In-Reply-To: <521C0104.2070906@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 09:29:40AM +0800, Fan Du wrote:
> On 2013=E5=B9=B408=E6=9C=8827=E6=97=A5 04:21, David Miller wrote:
> >
> >I don't understand why VTI doesn't need to propagate a PMTU update v=
ia
> >ipv4_update_pmtu().  Why is it different from a real xfrm_tunnel?
>   ^^^^^^^^^^^^^^^^
>=20
> A IPsec protected packet is first handled by protocol handlers, e.g A=
H/ESP,
> to check packet authentication or encryption rightness. PMTU update i=
s taken
> care of in this stage by protocol error handler.
>=20
> Then the packet is rearranged properly depending on whether it's tran=
sport
> mode or tunnel mode packed by mode "input" handler. The VTI handler c=
ode
> takes effects in this stage in tunnel mode only. So it neither need p=
ropagate
> PMTU, as it has already been done if necessary, nor the VTI handler i=
s
> qualified as a xfrm_tunnel.
>=20

I think you are right here, please update your commit message with
the above informations. I'd take this into ipsec-next and update
the the ipv6 vti patch according to your changes if David does not
mind.
