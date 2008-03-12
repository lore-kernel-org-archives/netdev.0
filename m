From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: question regarding (AF_INET6, SOCK_RAW, IPPROTO_RAW) sockets
Date: Wed, 12 Mar 2008 20:06:48 +0200
Message-ID: <200803122006.49506.rdenis@simphalempin.com>
References: <200803121834.29293.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47039 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501AbYCLSHE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 14:07:04 -0400
In-Reply-To: <200803121834.29293.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 12 March 2008 18:34:29 Octavian Purdila, vous avez =C3=A9c=
rit=C2=A0:
> Hi,
>
> I've noticed that when using IPv6 raw sockets with IPPROTO_RAW protoc=
ol and
> IPV6_PKTINFO set, we are not allow to specify a source address that i=
t is
> not configured in the system.
>
> Disabling ipv6_chk_addr in datagram_send_ctl for IPv6 raw sockets see=
ms to
> fix our problem. Is this approach the right one?

I am a bit confused here. Why would you use IPV6_PKTINFO with a network=
-layer=20
raw socket? You have to write the IPv6 header anyway, so what useful=20
additional infos would you the ancillary data contain?

--=20
R=C3=A9mi Denis-Courmont
