From: Alex <d77190@mail.ru>
Subject: Re: Bug 75571
Date: Thu, 05 Jun 2014 12:22:12 +0700
Message-ID: <1401945732.29664.6.camel@anpws>
References: <1401085231.1775.9.camel@anpws>
	 <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	 <1401870692.29664.1.camel@anpws>
	 <CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnat3.880.ru ([194.8.85.227]:6439 "EHLO stk-gw0.880.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750876AbaFEFV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 01:21:59 -0400
In-Reply-To: <CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=A1=D1=80, 04/06/2014 =D0=B2 17:27 -0700, Cong Wang =D0=BF=D0=
=B8=D1=88=D0=B5=D1=82:

> Thanks for testing!
>=20
> Thinking a bit more, the question is why
> skb_push(skb->dev->hard_header_len) is not correct here? It looks
> like we don't calculate tunnel->dev->hard_header_len correctly. But
> ipip_tunnel_bind_dev() should do the right thing less your setup is n=
ot
> correct, in that case your ipip tunnel should not receive any packet.
> We should be safe.
>=20
> Which is the interface routing to 192.168.18.17 on your system? Which
> driver does it use?

Its a stock e1000e from kernel with no special options. No jumbo frames=
,
etc.

lspci says:
Ethernet controller: Intel Corporation 82572EI Gigabit Ethernet
Controller (Copper) (rev 06)

IPIP tunnel runs on top of this interface.
