From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vlan: GRO rx statistics
Date: Sun, 15 Nov 2009 20:35:56 +0100
Message-ID: <4B00581C.3060303@gmail.com>
References: <4AF99A50.5080301@gmail.com> <4AFD8C31.10703@gmail.com> <20091114012741.GA18764@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59894 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbZKOTgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 14:36:02 -0500
In-Reply-To: <20091114012741.GA18764@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Fri, Nov 13, 2009 at 05:41:21PM +0100, Eric Dumazet wrote:
>> Still the race while updating dev->stats.tx_{bytes|packets} should b=
e addressed eventually...
>=20
> Well making it per-napi_struct should do the trick.

=46or normal devices, probably (but many of them use hardware counters =
anyway)
but not vlan :)

vlan_hwaccel_do_receive() has no napi context.

