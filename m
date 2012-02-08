From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 1/2] ipv4: Implement IP_UNICAST_IF socket option.
Date: Wed, 08 Feb 2012 20:28:43 +0100
Message-ID: <1328729323.2631.9.camel@edumazet-laptop>
References: <1328728268-22220-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:53508 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445Ab2BHT2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:28:47 -0500
Received: by wics10 with SMTP id s10so656237wic.19
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2012 11:28:46 -0800 (PST)
In-Reply-To: <1328728268-22220-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 f=C3=A9vrier 2012 =C3=A0 12:11 -0700, Erich E. Hoover a =
=C3=A9crit :
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch
> implements the feature by setting the outgoing interface in a similar
> fashion to that of IP_MULTICAST_IF.  A separate option is needed to
> handle this feature since the existing options do not provide all of
> the characteristics required by IP_UNICAST_IF, a summary is provided
> below.
>=20
> SO_BINDTODEVICE:
> * SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF
> does not.  From reading some old mailing list articles my
> understanding is that SO_BINDTODEVICE requires administrative
> privileges because it can override the administrator's routing
> settings.
> * The SO_BINDTODEVICE option restricts both outbound and inbound
> traffic, IP_UNICAST_IF only impacts outbound traffic.
>=20
> IP_PKTINFO:
> * Since IP_PKTINFO and IP_UNICAST_IF are independent options,
> implementing IP_UNICAST_IF with IP_PKTINFO will likely break some
> applications.
> * Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly
> complicates the Wine codebase and reduces the socket performance
> (doing this requires a lot of extra communication between the
> "server" and "user" layers).
>=20
> bind():
> * bind() does not work on broadcast packets, IP_UNICAST_IF is
> specifically intended to work with broadcast packets.
> * Like SO_BINDTODEVICE, bind() restricts both outbound and inbound
> traffic.
>=20
> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
> ---

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
