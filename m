From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 1/2] ipv4: Implement IP_UNICAST_IF socket option.
Date: Wed, 08 Feb 2012 15:52:19 -0500 (EST)
Message-ID: <20120208.155219.1385446744398832496.davem@davemloft.net>
References: <1328728268-22220-1-git-send-email-ehoover@mines.edu>
	<1328729323.2631.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ehoover@mines.edu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755805Ab2BHUwY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 15:52:24 -0500
In-Reply-To: <1328729323.2631.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Feb 2012 20:28:43 +0100

> Le mercredi 08 f=E9vrier 2012 =E0 12:11 -0700, Erich E. Hoover a =E9c=
rit :
>> The IP_UNICAST_IF feature is needed by the Wine project.  This patch
>> implements the feature by setting the outgoing interface in a simila=
r
>> fashion to that of IP_MULTICAST_IF.  A separate option is needed to
>> handle this feature since the existing options do not provide all of
>> the characteristics required by IP_UNICAST_IF, a summary is provided
>> below.
>>=20
>> SO_BINDTODEVICE:
>> * SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF
>> does not.  From reading some old mailing list articles my
>> understanding is that SO_BINDTODEVICE requires administrative
>> privileges because it can override the administrator's routing
>> settings.
>> * The SO_BINDTODEVICE option restricts both outbound and inbound
>> traffic, IP_UNICAST_IF only impacts outbound traffic.
>>=20
>> IP_PKTINFO:
>> * Since IP_PKTINFO and IP_UNICAST_IF are independent options,
>> implementing IP_UNICAST_IF with IP_PKTINFO will likely break some
>> applications.
>> * Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly
>> complicates the Wine codebase and reduces the socket performance
>> (doing this requires a lot of extra communication between the
>> "server" and "user" layers).
>>=20
>> bind():
>> * bind() does not work on broadcast packets, IP_UNICAST_IF is
>> specifically intended to work with broadcast packets.
>> * Like SO_BINDTODEVICE, bind() restricts both outbound and inbound
>> traffic.
>>=20
>> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
>> ---
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
