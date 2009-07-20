From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: getaddrinfo - too many recvmsg calls
Date: Mon, 20 Jul 2009 10:14:17 +0300
Message-ID: <200907201014.18063.remi.denis-courmont@nokia.com>
References: <dffc28000907200005p7effca1cif4060b15be99e84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Zsolt SZALAI <zs.szalai@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52316 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbZGTHMP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 03:12:15 -0400
In-Reply-To: <dffc28000907200005p7effca1cif4060b15be99e84@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 20 July 2009 10:05:56 ext Zsolt SZALAI wrote:
> The sanitycheck is now really simple, just a
>     addrinfo hints =3D { 0, AF_INET, 0, 0, 0, NULL, NULL, NULL };
>     int result =3D getaddrinfo(ipAddress, NULL, &hints, &addresses);
> call.

What the heck is this supposed to do?
This piece of code tries to resolve <ipAddress> as numerical IPv4 addre=
ss *or*=20
a DNS hostname.

If you want to check that a string is a valid IP address, call inet_pto=
n(). If=20
you want to check that an IP address is assigned to the system, create =
a=20
socket and bind to that address.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

