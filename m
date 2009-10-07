From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next-2.6] net: speedup sk_wake_async()
Date: Wed, 07 Oct 2009 05:37:02 +0200
Message-ID: <4ACC0CDE.1020907@gmail.com>
References: <4ACBCDD8.5000306@gmail.com> <4ACBE3E7.60404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53108 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbZJGDho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 23:37:44 -0400
In-Reply-To: <4ACBE3E7.60404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones a =E9crit :
>=20
> How about 64-bit?

No data yet, but larger footprint unfortunatly :-(

>=20
> Got any netperf service demand changes?

I was going to setup a bench lab, with a typical RTP mediaserver, with =
say
4000 UDP sockets, 2000 sockets exchanging 50 G.711 Alaw/ulaw
messages per second tx and rx. (Total : 100.000 packets per second each=
 way)

Is netperf able to simulate this workload ?
