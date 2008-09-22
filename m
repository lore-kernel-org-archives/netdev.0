From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: Receiving decrypted IPsec Packets including MAC source address
Date: Mon, 22 Sep 2008 11:37:21 +0300
Message-ID: <200809221137.21326.remi.denis-courmont@nokia.com>
References: <769319.35656.qm@web51402.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: pommnitz@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:27012 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbYIVIhq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 04:37:46 -0400
In-Reply-To: <769319.35656.qm@web51402.mail.re2.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 September 2008 11:25:11 ext Joerg Pommnitz, you wrote:
> Hello all,
> is there a way to get the source MAC address for a decrypted IPsec
> protected UDP packet? For unencrypted data I would use RAW sockets, b=
ut
> this obviously fails for encrypted data.

In either case, you would have to use PACKET sockets as INET raw socket=
s won't=20
give you the link-layer headers. But yeah, that would mean deciphering =
the=20
packets in userland.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
