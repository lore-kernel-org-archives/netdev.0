From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: allow disabling multilink protocol ID compression
Date: Tue, 21 Dec 2010 06:43:36 +0100
Message-ID: <1292910216.2627.156.camel@edumazet-laptop>
References: <20101220195833.26786ec5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33558 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab0LUFnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 00:43:42 -0500
In-Reply-To: <20101220195833.26786ec5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 19:58 -0800, Stephen Hemminger a =
=C3=A9crit :
> Linux would not connect to other router running old version Cisco IOS=
 (12.0).
> This is most likely a bug in that version of IOS, since it is fixed
> in later versions. As a workaround this patch allows a module paramet=
er
> to be set to disable compressing the protocol ID.
>=20
> See: https://bugzilla.vyatta.com/show_bug.cgi?id=3D3979
>=20
> RFC 1990 allows an implementation to formulate MP fragments as if pro=
tocol
> compression had been negotiated.  This allows us to always send compr=
essed
> protocol IDs.  But some implementations don't accept MP fragments wit=
h
> compressed protocol IDs.  This parameter allows us to interoperate wi=
th
> them.  The default value of the configurable parameter is the same as=
 the
> current behavior:  protocol compression is enabled.  If protocol comp=
ression
> is disabled we will not send compressed protocol IDs.
>=20
> This is based on an earlier patch by Bob Gilligan (using a sysctl).
> Module parameter is writable to allow for enabling even if ppp
> is already loaded for other uses.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


