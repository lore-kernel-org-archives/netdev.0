From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Sat, 28 May 2011 00:07:30 +0100
Message-ID: <1306537651.2029.196.camel@i7.infradead.org>
References: <1300357750.2589.46.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yuniverg, Michael" <michael.yuniverg@intel.com>,
	"Yedvab, Nadav" <nadav.yedvab@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55518 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757378Ab1E0XHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 19:07:32 -0400
In-Reply-To: <1300357750.2589.46.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 10:29 +0000, David Woodhouse wrote:
> We've discovered strange behaviour when we listen on in6addr_any and =
use
> SO_BINDTODEVICE to bind to the lo device.
>=20
> We can connect to any IPv4 address that is local to the machine, on a=
ny
> interface. (This is true whether we listen on AF_INET6/in6addr_any an=
d
> accept IPv4 connections on the IPv6 socket, or whether we just listen=
 on
> AF_INET/INADDR_ANY).
>=20
> The IPv6 behaviour is different =E2=80=94 the only IPv6 address that =
we can
> connect to is ::1.=20

Michael, Nadav =E2=80=95 did you ever get any further with this?

--=20
dwmw2

