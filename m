From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Mon, 16 Nov 2009 20:54:29 +0100
Message-ID: <4B01ADF5.8090904@gmail.com>
References: <4B019381.2010509@gmail.com> <20091116110207.08b60c81@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52229 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbZKPTyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 14:54:32 -0500
In-Reply-To: <20091116110207.08b60c81@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
>=20
> Or both..
>=20

Well well well :)

I was hoping a fast path, but anyway, a linkwatch_forget_dev(dev) is pr=
obably better,
(in case "ip link del" closely follows an "ip link add / up")

I'll post something when tested.

Thanks
