From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [Socketcan-users] [PATCH] CAN: make checking in can_rcv less restrictive
Date: Fri, 7 Aug 2009 09:52:56 +0300
Message-ID: <200908070952.56922.remi.denis-courmont@nokia.com>
References: <1249572295-7801-1-git-send-email-l.fu@pengutronix.de> <4A7B0957.5020808@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luotao Fu <l.fu@pengutronix.de>,
	"socketcan-users@lists.berlios.de" <socketcan-users@lists.berlios.de>,
	Michael Olbrich <m.olbrich@pengutronix.de>
To: ext Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:34667 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbZHGGxN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 02:53:13 -0400
In-Reply-To: <4A7B0957.5020808@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving to netdev....

On Thursday 06 August 2009 19:48:23 ext Oliver Hartkopp wrote:
> The CAN applications can rely on getting proper CAN frames with this =
check.
> It was introduced some time ago together with several other sanity ch=
ecks -
> even on the TX path.
>
> The CAN core *only* consumes skbuffs originated from a CAN netdevice
> (ARPHRD_CAN).
>
> When this BUG() triggers, someone provided a definitely broken *CAN*
> network driver, and this needs to be fixed on that level. It is reall=
y not
> that problematic to ensure proper CAN frames on driver level ... this
> sanity check should not be needed to be performed by every single
> application.

AFAIK, the TUN driver can inject layer-2 frames of any type, any size a=
nd any=20
content from userspace into the packet type handler. Sure enough, you n=
eed=20
CAP_NET_ADMIN and r/w access to /dev/net/tun but is it sufficient to br=
ing the=20
system down?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

