From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gianfar: multi queue stuff not complete
Date: Thu, 19 Nov 2009 10:13:09 +0100
Message-ID: <4B050C25.5010309@gmail.com>
References: <4B05019F.4090208@gmail.com> <9F4C7D19E8361D4C94921B95BE08B81B950E25@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55606 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbZKSJNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 04:13:08 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950E25@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gopalpet-B05799 a =E9crit :
>=20
> Eric, Yes I agree that still there are a couple of changes left and I=
 am
> working on it.
> One of them being the stats. Currently caught up in something else, I
> will update them ASAP.
>=20
> Also, suggest me on what kind of stats do I need to maintain ? Both p=
er
> device and per queue
> or only per queue would be sufficient ?
>=20
Optimum would be per queue only, to avoid locking and let each queue be=
 really independant.

