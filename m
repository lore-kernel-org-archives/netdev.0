From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:30:36 +0100
Message-ID: <4B07188C.2070808@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <87aayg539l.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35878 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436AbZKTWaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:30:39 -0500
In-Reply-To: <87aayg539l.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
>=20
> Do you have numbers on this? It seems like a lot of effort to avoid t=
ransfering
> a few cache lines.

Lot of efforts ? hmm...

>=20
> -Andi (who is a bit sceptical and would rather see generic work for t=
his in slab)
>=20

Yes, I know, but slab/slub is already quite optimized :)

Coding XPS was more a way to try to help push RPS in, I did not benchma=
rked it BTW.

My new dev machine is up, with two E5530 cpus and a 82599EB 10-Gigabit =
dual port card :
Pretty amazing :=3D)

