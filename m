From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] niu: RX queues should rotate if budget exhausted
Date: Fri, 27 Mar 2009 09:05:20 +0100
Message-ID: <49CC88C0.6040900@cosmosbay.com>
References: <49CB8DFD.2050504@cosmosbay.com>	<49CBC8CC.1090807@cosmosbay.com>	<20090327.005546.109440539.davem@davemloft.net> <20090327.005828.173228960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesper@krogh.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44721 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbZC0IFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 04:05:30 -0400
In-Reply-To: <20090327.005828.173228960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :

>> Anyways, I'll apply this directly, thanks a lot!
>=20
> Actually, I take that back... I want to do this slightly
> differently.
>=20
> That niu_poll_core() is used in both the MSI-X and non-MSI
> case.
>=20
> I always meant to fix this driver to not scan over all the
> RX rings when we use MSI-X and the event can only be for
> one specific queue.
>=20
> Then we can add your rotating logic to the non-MSI-X interrupt
> paths.

Great, I'll take care of this.

Thanks



